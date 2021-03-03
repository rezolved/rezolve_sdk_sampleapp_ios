import UIKit

extension String {
    var uppercaseFirstLetter: String {
        prefix(1).uppercased() + dropFirst()
    }
}

extension Decimal {
    var toDouble: Double {
        return Double(truncating: self as NSNumber? ?? 0)
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UIImageView {
    struct AnimationConsts {
        static let fadeTimeInterval: TimeInterval = 0.2
    }
    
    public func imageFromUrl(url: URL) {
        DispatchQueue.global().async {
            let data = try! Data(contentsOf: url)
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }
    }
}

extension UITextView {
    @discardableResult
    func addImageWithInsets(_ namedImg: String) -> UIImageView? {
        guard !self.subviews.contains(where: { (view) -> Bool in
                view.tag == 1
            }) else { return nil }
        
        let arrowWidth: CGFloat = 13
        let arrowHeight: CGFloat = 8
        
        let arrow = UIImageView(frame: CGRect(x: self.frame.width - 20, y: (self.frame.height / 2) - arrowHeight, width: arrowWidth, height: arrowHeight))
        arrow.image = UIImage(named: namedImg)
        arrow.contentMode = .scaleAspectFit
        arrow.tag = 1
        self.addSubview(arrow)
        
        self.textContainerInset = UIEdgeInsets(top: 0, left: 5, bottom: 10, right: 20)
        
        return arrow
    }
}
