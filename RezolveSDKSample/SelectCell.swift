import UIKit
import RezolveSDK

final class SelectCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    func configure(with model: Page.Element.Select) {
        let text = model.text ?? ""
        let isRequired = model.isRequired ? "*" : ""
        label.text = "\(text) \(isRequired)"
        if model.isValid {
            label.textColor = .black
        } else {
            label.textColor = .systemRed
        }
        
        valueLabel.text = model.value?.description ?? "Tap to select an option"
    }
}
