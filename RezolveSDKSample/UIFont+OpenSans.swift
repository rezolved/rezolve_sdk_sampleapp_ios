import UIKit

extension UIFont {
    
    enum OpenSans: String {
        case bold = "OpenSans-Bold"
        case boldItalic = "OpenSans-BoldItalic"
        case extraBold = "OpenSans-ExtraBold"
        case extraBoldItalic = "OpenSans-ExtraBoldItalic"
        case italic = "OpenSans-Italic"
        case light = "OpenSans-Light"
        case lightItalic = "OpenSans-LightItalic"
        case regular = "OpenSans"
        case semibold = "OpenSans-Semibold"
        case semiboldItalic = "OpenSans-SemiboldItalic"
        
        static func font(ofSize size: CGFloat, type: OpenSans) -> UIFont {
            UIFont(name: type.rawValue, size: size)!
        }
        
        static func bold(ofSize size: CGFloat) -> UIFont {
            font(ofSize: size, type: .bold)
        }
        
        static func boldItalic(ofSize size: CGFloat) -> UIFont {
            font(ofSize: size, type: .boldItalic)
        }
        
        static func extraBold(ofSize size: CGFloat) -> UIFont {
            font(ofSize: size, type: .extraBold)
        }
        
        static func extraBoldItalic(ofSize size: CGFloat) -> UIFont {
            font(ofSize: size, type: .extraBoldItalic)
        }
        
        static func italic(ofSize size: CGFloat) -> UIFont {
            font(ofSize: size, type: .italic)
        }
        
        static func light(ofSize size: CGFloat) -> UIFont {
            font(ofSize: size, type: .light)
        }
        
        static func lightItalic(ofSize size: CGFloat) -> UIFont {
            font(ofSize: size, type: .lightItalic)
        }
        
        static func regular(ofSize size: CGFloat) -> UIFont {
            font(ofSize: size, type: .regular)
        }
        
        static func semibold(ofSize size: CGFloat) -> UIFont {
            font(ofSize: size, type: .semibold)
        }
        
        static func semiboldItalic(ofSize size: CGFloat) -> UIFont {
            font(ofSize: size, type: .semiboldItalic)
        }
    }
}
