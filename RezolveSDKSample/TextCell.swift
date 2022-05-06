import UIKit
import RezolveSDK

final class TextCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    func configure(with text: Page.Element.Text) {
        label.text = text.text
        switch text.type {
        case .header:
            label.font = .systemFont(ofSize: 20, weight: .semibold)
        default:
            label.font = .systemFont(ofSize: 16, weight: .regular)
        }
    }
}
