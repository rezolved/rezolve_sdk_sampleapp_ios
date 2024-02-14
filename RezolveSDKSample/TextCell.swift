import UIKit
import RezolveSDK

final class TextCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    func configure(with text: Page.Element.Text) {
        label.text = text.text
        switch text.type {
        case .header:
            label.font = .systemFont(ofSize: 24, weight: .semibold)
        default:
            label.font = .systemFont(ofSize: 16, weight: .regular)
        }
        self.backgroundColor = hexStringToUIColor(hexString: text.style.backgroundColor)
    }
}

private func hexStringToUIColor(hexString: String) -> UIColor {
    var string = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (string.hasPrefix("#")) {
        string.remove(at: string.startIndex)
    }
    
    if ((string.count) != 6) {
        return UIColor.gray
    }
    
    var colorValue: UInt64 = 0
    Scanner(string: string).scanHexInt64(&colorValue)
    
    return UIColor(red: CGFloat((colorValue & 0xff0000) >> 16) / 255.0, green: CGFloat((colorValue & 0x00ff00) >> 8) / 255.0, blue: CGFloat(colorValue & 0x0000ff) / 255.0, alpha: CGFloat(1.0))
}
