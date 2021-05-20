import RezolveSDK
import AVFoundation

enum CaptureError {
    case abortedRecord
    case cannotStartRecord
    case preprocessingPhoto
    case api(RezolveError)
}

protocol CaptureLayerDelegate: AnyObject {
    func didStartDiscovering()
    func didDiscover(engagement: ResolverEngagement, eventType: RezolveEventReport.RezolveEventReportType)
    func didFailDiscovering(error: CaptureError)
}

protocol RemoteResolver: AnyObject {
    var remoteScanner: RemoteScanResolver? { get }
    var delegate: CaptureLayerDelegate? { get }
}

extension RemoteResolver {
    
    func scanImage(data: Data, failure: (() -> ())? = nil) {
        delegate?.didStartDiscovering()
        remoteScanner?.resolveImage(image: data) { [weak self] (result) in
            guard let self = self else { return }
            self.consumeResponse(result: result, event: .image, failure: failure)
        }
    }
    
    func scanAudio(data: Data) {
        delegate?.didStartDiscovering()
        remoteScanner?.resolveAudio(audio: data) { [weak self] (result) in
            guard let self = self else { return }
            self.consumeResponse(result: result, event: .audio)
        }
    }
    
    private func consumeResponse(result: Result<ResolverEngagement, RezolveError>,
                                 event: RezolveEventReport.RezolveEventReportType,
                                 failure: (() -> ())? = nil) {
        switch result {
        case .success(let engagement):
            self.delegate?.didDiscover(engagement: engagement, eventType: event)
        case .failure(let error):
            if let failure = failure {
                failure()
            } else {
                self.delegate?.didFailDiscovering(error: .api(error))
            }
        }
    }
}
