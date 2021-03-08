import Foundation
import RezolveSDK

typealias SspActSubmissionData = (answers: [SspActSubmissionDetails], userDetails: SspActUserDetails)

final class UserSspActSubmissionHandler {
    
    enum Answers {
        @available(*, deprecated, message: "Backward compatibility for SspAct submission")
        case answers([SspSubmissionAnswer])
        case page(Page)
        
        var answers: [SspSubmissionAnswer] {
            switch self {
            case .answers(let answers):
                return answers
            case .page(let page):
                return page.elements.compactMap(answer)
            }
        }
        
        private func answer(element: Page.Element) -> SspSubmissionAnswer? {
            switch element {
            case .dateField(let dateField):
                guard let value = dateField.valueText else {
                    return nil
                }
                return SspSubmissionAnswer(questionId: dateField.id, answer: value)
            case .textField(let textField):
                guard let text = textField.value else {
                    return nil
                }
                return SspSubmissionAnswer(questionId: textField.id, answer: text)
            case .select(let select):
                guard let value = select.value else {
                    return nil
                }
                return SspSubmissionAnswer(questionId: select.id, answer: String(value.value))
            case .text, .divider, .image, .video:
                return nil
            }
        }
    }
    
    // MARK: - Ssp Act
    
    private let sspActManager: SspActManager
    private let sspAct: SspAct
    private let answers: Answers
    private let location: CLLocation?
    
    private var sspActSubmissionDetails: SspActSubmissionData
    
    // MARK: - Calculated Act properties
    
    private var actSubmission: SspActSubmission {
        return SspActSubmission(
            userId: "",
            userName: "",
            personTitle: "",
            firstName: "",
            lastName: "",
            email: "",
            phone: nil,
            scanId: nil,
            latitude: nil,
            longitude: nil,
            answers: answers.answers
        )
    }
    
    // MARK: - Init
    
    init(sspActManager: SspActManager, sspAct: SspAct, answers: Answers, location: CLLocation?) {
        self.sspActManager = sspActManager
        self.sspAct = sspAct
        self.answers = answers
        self.location = location
        self.sspActSubmissionDetails.answers = [SspActSubmissionDetails(title: sspAct.name)]
        self.sspActSubmissionDetails.userDetails = SspActUserDetails()
    }
    
    // MARK: - Act Submission
    
    func submitAct(completionHandler: @escaping (_ result: Result<SspActSubmissionData, RezolveError>) -> Void) {
        sspActManager.submitAct(actId: sspAct.id, actSubmission: actSubmission) { (result: Result<SspActSubmission, RezolveError>) in

            switch result {
            case .success(let response):
                let userSspActSubmissionDetails = self.getUserSspActSubmission(from: response)
                self.sspActSubmissionDetails.answers.append(contentsOf: userSspActSubmissionDetails)
                
                self.sspActSubmissionDetails.userDetails = SspActUserDetails(
                    firstName: response.firstName,
                    lastName: response.lastName,
                    email: response.email,
                    phone: response.phone
                )

                completionHandler(.success(self.sspActSubmissionDetails))
            case .failure(let error):
                completionHandler(.failure(error))
            }

        }
    }
    
    private func getUserSspActSubmission(from sspActSubmission: SspActSubmission) -> [SspActSubmissionDetails] {
        if case .page(let page) = answers {
            return page.elements.compactMap(answerDetails)
        }
        let userSspActSubmission = sspActSubmission.answers.compactMap { (sspSubmission) -> SspActSubmissionDetails? in
            guard let question = sspAct.questions?.first(where: { $0.id == sspSubmission.questionId }) else {
                return nil
                
            }
            switch question.type {
            case .dropDown:
                guard let answer = question.values?.first(where: { $0.id == sspSubmission.answer }) else {
                    return nil
                }
                return SspActSubmissionDetails(title: question.title, details: answer.title)
            case .date, .field:
                return SspActSubmissionDetails(title: question.title, details: sspSubmission.answer)
            }
        }
        
        return userSspActSubmission
    }
    
    private func answerDetails(element: Page.Element) -> SspActSubmissionDetails? {
        switch element {
        case .dateField(let dateField):
            return SspActSubmissionDetails(title: dateField.text ?? "", details: dateField.valueText)
        case .textField(let textField):
            return SspActSubmissionDetails(title: textField.text ?? "", details: textField.value)
        case .select(let select):
            return SspActSubmissionDetails(title: select.text ?? "", details: select.value?.description)
        case .text, .divider, .image, .video:
            return nil
        }
    }
}
