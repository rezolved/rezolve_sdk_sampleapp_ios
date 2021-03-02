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
    
    func setBorders(color: UIColor) {
        if let sublayers = self.layer.sublayers {
            sublayers.forEach({
                if  $0.name == TextViewBorder.bottomBorder.rawValue ||
                    $0.name == TextViewBorder.leftBorder.rawValue ||
                    $0.name == TextViewBorder.rightBorder.rawValue
                {
                    $0.removeFromSuperlayer()
                }
            })
        }
        setBottomBorder(color: color)
        setSidesBorder(color: color)
    }
    
    func setBottomBorder(color: UIColor) {
        
        let borderW: CGFloat = 1.5
        
        let bottomLine = CALayer()
        bottomLine.name = TextViewBorder.bottomBorder.rawValue
        bottomLine.frame = CGRect(x: borderW, y: self.frame.height - borderW, width: self.frame.width - (borderW*2), height: borderW)
        bottomLine.backgroundColor = color.cgColor
        self.layer.addSublayer(bottomLine)
    }
    
    func setSidesBorder(color: UIColor) {
        
        let h = self.frame.size.height-20
        
        let y = self.frame.height - h
        
        let borderW: CGFloat = 1.5
        
        // Left border
        let leftLine = CALayer()
        leftLine.name = TextViewBorder.leftBorder.rawValue
        leftLine.frame = CGRect(x: 0.0, y: y, width: borderW, height: h)
        leftLine.backgroundColor = color.cgColor
        
        self.layer.addSublayer(leftLine)
        
        // Right border
        let rightLine = CALayer()
        rightLine.name = TextViewBorder.rightBorder.rawValue
        rightLine.frame = CGRect(x: self.bounds.size.width-borderW, y: y, width: borderW, height: h)
        rightLine.backgroundColor = color.cgColor
        
        self.layer.addSublayer(rightLine)
    }
    
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
