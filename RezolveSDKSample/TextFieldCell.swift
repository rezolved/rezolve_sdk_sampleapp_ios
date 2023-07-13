import UIKit
import RezolveSDK

protocol TextFieldCellDelegate: AnyObject {
    func textFieldCell(_ cell: TextFieldCell, didChangeText text: String, model: Page.Element.TextField)
}

final class TextFieldCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    weak var delegate: TextFieldCellDelegate?
    
    private var model: Page.Element.TextField?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let model = model else {
            return
        }
        delegate?.textFieldCell(self, didChangeText: textField.text ?? "", model: model)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func configure(with model: Page.Element.TextField) {
        self.model = model
        let text = model.text ?? ""
        let isRequired = model.isRequired ? "*" : ""
        label.text = "\(text) \(isRequired)"
        if model.isValid {
            label.textColor = .black
        } else {
            label.textColor = .systemRed
        }
        textField.text = model.value
    }
}
