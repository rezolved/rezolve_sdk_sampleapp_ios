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
    public func imageFromUrl(url: URL) {
        DispatchQueue.global().async {
            let data = try! Data(contentsOf: url)
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }
    }
}
