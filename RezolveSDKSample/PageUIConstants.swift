import UIKit
import RezolveSDK

enum PageUIConstants {
    static let separatorColor = UIColor(hex: 0xCCCCCC, alpha: 1)
    static let fieldBackgroundColor = UIColor(hex: 0xF6F6F6, alpha: 1)
    
    static let defaultSpacing = CGFloat(15)
    
    static let paragraphPadding = UIEdgeInsets(top: 5, left: defaultSpacing, bottom: 5, right: defaultSpacing)
    static let paragraphMargin = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    static let headerPadding = UIEdgeInsets(top: 10, left: defaultSpacing, bottom: 10, right: defaultSpacing)
    static let headerMargin = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    
    static let textDecorator = TextDecorator(
        fontConfiguration: .init(
            header: .init(
                regular: UIFont.OpenSans.regular(ofSize: 18),
                regularItalic: UIFont.OpenSans.italic(ofSize: 18),
                bold: UIFont.OpenSans.bold(ofSize: 18),
                boldItalic: UIFont.OpenSans.boldItalic(ofSize: 18)
            ),
            paragraph: .init(
                regular: UIFont.OpenSans.regular(ofSize: 14),
                regularItalic: UIFont.OpenSans.italic(ofSize: 14),
                bold: UIFont.OpenSans.bold(ofSize: 14),
                boldItalic: UIFont.OpenSans.boldItalic(ofSize: 14)
            )
        )
    )
}
