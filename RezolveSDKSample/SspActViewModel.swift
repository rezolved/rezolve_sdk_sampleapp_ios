import Foundation
import RezolveSDK

protocol SspActViewModelDelegate: class {
    func display(items: [Page.Element])
    func enableSubmitView(isEnabled: Bool)
    func actSubmissionFailed(with error: RezolveError)
    func actSubmissionSucceed()
}

final class SspActViewModel {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    private(set) var page: Page!
    let sspAct: SspAct
    
    weak var delegate: SspActViewModelDelegate?
    
    init(sspAct: SspAct) {
        self.sspAct = sspAct
    }
    
    func loadPage() {
        guard let form = sspAct.pageBuildingBlocks else {
            return
        }
        page = PageBuilder().buildIgnoringErros(elements: form)
        delegate?.display(items: page.elements)
        validatePage()
    }
    
    func validatePage() {
        if sspAct.isInformationPage ?? false {
            return
        }
        delegate?.enableSubmitView(isEnabled: page.isValid)
    }
    
    func submit(sspActManager: SspActManager, location: CLLocation?) {
        sspActManager.submitAct(
            actId: sspAct.id,
            actSubmission: prepareSubmission(location: location)
        ) { [weak self] (result) in
            guard let self = self else {
                return
            }
            
            switch result {
            case .failure(let error):
                self.delegate?.actSubmissionFailed(with: error)
            case.success:
                self.delegate?.actSubmissionSucceed()
            }
        }
    }
    
    private func prepareSubmission(location: CLLocation?) -> SspActSubmission {
        let guestUser = Storage.load()
        
        return SspActSubmission(
            userId: guestUser?.id.string,
            userName: guestUser?.username,
            personTitle: nil,
            firstName: guestUser?.firstName,
            lastName: guestUser?.lastName,
            email: guestUser?.email,
            phone: guestUser?.phone,
            scanId: nil,
            latitude: location?.coordinate.latitude,
            longitude: location?.coordinate.longitude,
            answers: page.elements.compactMap(answer)
        )
    }
    
    private func answer(element: Page.Element) -> SspSubmissionAnswer? {
        switch element {
        case .dateField(let dateField):
            guard let value = dateField.value else {
                return nil
            }
            let date = dateFormatter.string(from: value)
            return SspSubmissionAnswer(questionId: dateField.id, answer: date)
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
        default:
            return nil
        }
    }
}
