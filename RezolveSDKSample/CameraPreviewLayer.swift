import AVFoundation
import RezolveSDK

protocol CameraPreviewLayer: AnyObject {
    var scanCameraView: ScanCameraView! { get }
    var session: AVCaptureSession? { get set }
}

extension CameraPreviewLayer {
    
    func startSession(success: ((AVCaptureSession) -> ())? = nil) {
        if Platform.isSimulator {
            return
        }
        
        let permissionFor = { (mediaType: AVMediaType, next: @escaping ((Bool) -> Void)) in
            AVCaptureDevice.requestAccess(for: mediaType, completionHandler: next)
        }
        
        permissionFor(AVMediaType.video as AVMediaType) { allowedVideo in
            permissionFor(AVMediaType.audio as AVMediaType) { allowedAudio in
                DispatchQueue.main.async {
                    self.startSession()
                    if let session = self.session, session.isRunning {
                        success?(session)
                    }
                }
            }
        }
    }
    
    private func startSession() {
        if Platform.isSimulator {
            return
        }
        startSession(cameraView: scanCameraView)
    }
    
    private func startSession(cameraView: ScanCameraView) {
        stopSession()
        
        let videoSession = AVCaptureSession()
        videoSession.sessionPreset = .photo
        
        guard let inputDevice: AVCaptureDeviceInput = AVCaptureDeviceInput.videoInputDevice,
              videoSession.canAddInput(inputDevice) else {
            return
        }
        videoSession.beginConfiguration()
        videoSession.addInput(inputDevice)
        videoSession.commitConfiguration()
        videoSession.startRunning()
        
        self.session = videoSession
        cameraView.session = videoSession
        
        if case .some(let preview) = scanCameraView.layer as? AVCaptureVideoPreviewLayer {
            preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }
    }
    
    public func stopSession() {
        if session != nil && (session?.isRunning)! {
            session?.stopRunning()
            session = nil
        }
    }
}
