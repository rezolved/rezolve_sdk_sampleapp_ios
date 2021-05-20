import AVFoundation
import CoreImage

extension CGImage {
    
    func cgContext(size: CGSize) -> CGContext? {
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                bitmapInfo: bitmapInfo.rawValue)
        context?.interpolationQuality = .high
        return context
    }
    
    func aspectFill(size: CGSize) -> CGImage? {
        let scale = max(size.width / CGFloat(width), size.height / CGFloat (height))
        return croppedCenter(size: size, scale: scale)
    }
    
    func croppedCenter(size: CGSize, scale: CGFloat) -> CGImage? {
        let context = cgContext(size: size)
        let totalSize = CGSize(width: CGFloat(width) * scale, height: CGFloat(height) * scale)
        let origin = CGPoint(x: -(totalSize.width - size.width) / 2,
                             y: -(totalSize.height - size.height) / 2)
        context?.draw(self, in: CGRect(origin: origin, size: totalSize))
        return context?.makeImage()
    }
}

extension CIImage {
    var compressedData: Data? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let data = CIContext()
                .jpegRepresentation(of: self,
                                    colorSpace: colorSpace)
            else {
            return nil
        }
        return data
    }
}
