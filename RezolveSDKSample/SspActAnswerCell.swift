import Foundation
import RezolveSDK

protocol SspActAnswerCellDelegate: AnyObject {
    func sspActAnswerCell(_ sspActAnswerCell: SspActAnswerCell, didBeginEditing textView: UITextView)
    func sspActAnswerCell(_ sspActAnswerCell: SspActAnswerCell, didSetAnswerFrom source: AnswerSource)
}

enum AnswerSource {
    case date(Date), text(UITextView), questionValue(SspActQuestionValue)
    
    var formattedAnswer: String? {
        switch self {
        case .date(let selectedDate):
            return AbbreviatedMonthDateFormatter.getMonthWithoutDotDateText(currentDate: selectedDate)
        case .text(let textView):
            return textView.text
        case .questionValue(let selectedValue):
            return selectedValue.title
        }
    }
    
    var isValid: Bool {
        switch self {
        case .date, .questionValue:
            return true
        case .text(let textView):
            return !textView.text.isEmpty && !textView.text.isWhitespace
        }
    }
    
    var answerValue: String? {
        switch self {
        case .date, .text:
            return formattedAnswer
        case .questionValue(let value):
            return value.id
        }
    }
    
}

private enum TextStatus {
    case answer, question, empty
}

enum TextViewBorder: String, CaseIterable {
    case bottomBorder, leftBorder, rightBorder
}

class SspActAnswerCell: UITableViewCell {
    
    // MARK: - Properties / Delegates
    
    private var date: Date?
    
    private var question: SspActQuestion?
    private var answer: String? {
        willSet (newAnswer) {
            setupTextViewText(basedOn: newAnswer)
        }
    }
        
    weak var delegate: SspActAnswerCellDelegate?
    
    // MARK: - Views
    
    lazy var answerTextView: UITextView = {
        let textView = UITextView()
        
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 5, bottom: 10, right: 20)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(textView)
        
        textView.delegate = self
        textView.isScrollEnabled = false
        isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = false
        
        return textView
    }()
    
    private var dropDownArrow: UIImageView?
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textViewAnswerTextViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        textViewAnswerTextViewConstraints()
    }
    
    private func textViewAnswerTextViewConstraints() {
        let spacingConstant: CGFloat = 12
        
        NSLayoutConstraint.activate(
            [
                answerTextView.topAnchor.constraint(equalTo: topAnchor, constant: spacingConstant),
                answerTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -spacingConstant),
                answerTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacingConstant),
                answerTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacingConstant),
            ]
        )
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addAdditionalViewsIfNeedIt()
        answerTextView.layoutIfNeeded()
    }
    
    private func addAdditionalViewsIfNeedIt() {
        answerTextView.setBorders(color: .lightGray)
        if question?.type != .some(.field) {
            dropDownArrow = answerTextView.addImageWithInsets("FIELD_ARROW_DOWN")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dropDownArrow?.removeFromSuperview()
        removeAllBorders()
    }
    
    private func removeAllBorders() {
        answerTextView.layer.sublayers?.forEach { subLayer in
            guard TextViewBorder.allCases.contains(where: { $0.rawValue == subLayer.name } ) else { return }
            subLayer.removeFromSuperlayer()
        }
        return
        
    }
    
    // MARK: - UI Configuration/Management
    
    func setup(question: SspActQuestion, answer: String? = nil) {
        self.question = question
        self.answer = answer
        
        answerTextView.text = answer ?? getFormattedQuestionText()
        
        configureCell()
    }
    
    private func getFormattedQuestionText() -> String? {
        guard
            question?.required == true,
            let title = question?.title
            else {
                return question?.title
        }
        return "* \(title)"
    }
    
    private func configureCell() {
        switch question?.type {
        case .field:
            answerTextView.isUserInteractionEnabled = true
            cellViewTapGesture.isEnabled = false
        case .date, .dropDown:
            answerTextView.isUserInteractionEnabled = false
            cellViewTapGesture.isEnabled = true
        default:
            answerTextView.isUserInteractionEnabled = false
            cellViewTapGesture.isEnabled = false
        }
    }
    
    private func setupTextViewText(basedOn answer: String?) {
        switch getTextStatus(answer) {
        case .answer:
            answerTextView.text = answer
            answerTextView.textColor = .black
        case .question:
            answerTextView.text = nil
            answerTextView.textColor = .red
        case .empty:
            answerTextView.text = question?.title
            answerTextView.textColor = .red
        }
    }
    
    private func getTextStatus(_ text: String?) -> TextStatus {
        switch true {
        case text?.contains(question?.title ?? "") ?? true: return .question
        case text.isNilOrEmpty: return .empty
        default: return .answer
        }
    }
    
    // MARK: - Model picker
    //  Imitate checkout implementation
    //  After RCE Acts deportation, this implementation should be reconsider
    private var payload: [String: Any?] = [:]
    private var actualPosition = -1
    private func setupDropDownPayload() {
        guard let questions = question?.values else { return }
        
        payload = [
            "data": question?.values?.compactMap { $0.title },
            "lastDataSelected": {
                if actualPosition == -1 { return "" }
                return questions[safe: actualPosition]?.title
            }(),
            "title": question?.title,
            "callback": { [weak self] (position: Int) -> Void in
                guard
                    let self = self,
                    let questionValue = questions[safe: position]
                    else {
                        return
                }
                let id = questions[safe: position]?.id ?? "-1"
                self.actualPosition = Int(id) ?? -1
                self.answer = questionValue.title
                self.delegate?.sspActAnswerCell(self, didSetAnswerFrom: .questionValue(questionValue))
                
            }]
    }
    
    private func setupDatePickerPayload() {
        payload = [
            "title": question?.title,
            "value": date,
            "callback": {  [weak self] (selectedDate: Date) -> Void in
                guard let self = self else { return }
                self.answer = AbbreviatedMonthDateFormatter.getMonthWithoutDotDateText(currentDate: selectedDate)
                self.delegate?.sspActAnswerCell(self, didSetAnswerFrom: .date(selectedDate))
                
            }
        ]
    }
    
    lazy var cellViewTapGesture: UITapGestureRecognizer = {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(showPickerVC))
        addGestureRecognizer(singleTap)
        
        return singleTap
    }()
    
    @objc private func showPickerVC() {
        switch question?.type {
        case .date:
            showDatePickerVC()
        case .dropDown:
            showDropDownVC()
        default: break
        }
    }
    
    @objc private func showDropDownVC() {
        setupDropDownPayload()
        
        guard !payload.isEmpty else { return }
    }
    
    @objc private func showDatePickerVC() {
        setupDatePickerPayload()
        
        guard !payload.isEmpty else { return }
    }
}

extension SspActAnswerCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.sspActAnswerCell(self, didBeginEditing: textView)
        
        let isAnswerContainsQuestion = textView.text.contains(question?.title ?? "")
        
        if isAnswerContainsQuestion {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.answer = nil
                textView.textColor = .black
            }
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        answer = textView.text
        delegate?.sspActAnswerCell(self, didSetAnswerFrom: .text(textView))
    }
    
}
