import UIKit
import RezolveSDK

final class DateFieldCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    func configure(with model: Page.Element.DateField) {
        let text = model.text ?? ""
        let isRequired = model.isRequired ? "*" : ""
        label.text = "\(text) \(isRequired)"
        if model.isValid {
            label.textColor = .black
        } else {
            label.textColor = .systemRed
        }
        
        if let value = model.value {
            valueLabel.text = formatter.string(from: value)
        } else {
            valueLabel.text = "Tap to select a date"
        }
    }
}
