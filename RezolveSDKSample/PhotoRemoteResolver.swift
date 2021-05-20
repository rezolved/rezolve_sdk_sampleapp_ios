import RezolveSDK
import AVFoundation

final class PhotoRemoteResolver: NSObject, RemoteResolver {
    
    private var capturePhotoOutput: AVCapturePhotoOutput?
    
    lazy var remoteScanner: RemoteScanResolver? = RezolveService.session?.remoteScanResolver
    weak var delegate: CaptureLayerDelegate?
    let scanPhotoSize = CGSize(width: 1280, height: 720)
    
    func attatchToSession(session: AVCaptureSession) {
        
        let photoOutput = AVCapturePhotoOutput()
        
        guard
            session.canAddOutput(photoOutput)
        else { return }
        session.addOutput(photoOutput)
        self.capturePhotoOutput = photoOutput
    }
    
    func capturePicture() {
        let pixelFormatType = kCVPixelFormatType_32BGRA
        let settings = AVCapturePhotoSettings(
            format:  [ kCVPixelBufferPixelFormatTypeKey as String : pixelFormatType]
        )
        capturePhotoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    func processImage(_ image: CGImage, next: (() -> ())?, processBlock: (CGImage) -> (CGImage?)) {
        guard let processedImage = processBlock(image)
        else {
            next?()
            return
        }
        let imageProcessed = CIImage(cgImage: processedImage)
        guard let data = imageProcessed.compressedData
        else {
            next?()
            return
        }
        scanImage(data: data, failure: next)
    }
    
    func processImageAspectFill(_ image: CGImage, next: (() -> ())?) {
        processImage(image, next: next) { image in
            return image.aspectFill(size: scanPhotoSize)
        }
    }
    
    func processImageMiddleCropResize(_ image: CGImage, next: (() -> ())?) {
        processImage(image, next: next) { image in
            return image.croppedCenter(size: scanPhotoSize, scale: 0.65)
        }
    }
    
    func processImageMiddleCropCenter(_ image: CGImage, next: (() -> ())?) {
        processImage(image, next: next) { image in
            return image.croppedCenter(size: scanPhotoSize, scale: 1.0)
        }
    }
    
}

extension PhotoRemoteResolver: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let cgImageUnmanaged = photo.cgImageRepresentation() else {
            delegate?.didFailDiscovering(error: .preprocessingPhoto)
            return
        }
        let image = cgImageUnmanaged.takeUnretainedValue()
        
        // Slicing and resizing part of picture can give more accurate results
        processImageAspectFill(image) { [weak self] in
            self?.processImageMiddleCropResize(image, next: nil)
        }
    }
}

extension AVCaptureDeviceInput {
    
    static var videoInputDevice: AVCaptureDeviceInput? {
        let captureDevice: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)!
        return try? AVCaptureDeviceInput(device: captureDevice)
    }
}
