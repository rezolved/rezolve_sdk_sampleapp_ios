import RezolveSDK
import AVFoundation

final class AudioRemoteResolver: NSObject, RemoteResolver {
    
    var recordingAudio: Bool = false
    var audioRecorder: AVAudioRecorder?
    var cutoffTimer: Timer?
    let recordLength: TimeInterval = 13.0
    
    lazy var remoteScanner: RemoteScanResolver? = RezolveService.session?.remoteScanResolver
    weak var delegate: CaptureLayerDelegate?
    
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        _ = try? session.setCategory(.record, options: [])
        let recordSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey: 16000,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false
        ]
        let recordUrl = getRecordUrl()
        do {
            let recorder = try AVAudioRecorder(
                url: recordUrl,
                settings: recordSettings
            )
            recorder.prepareToRecord()
            recorder.record()
            audioRecorder = recorder
            recordingAudio = true
            cutoffTimer = Timer.scheduledTimer(withTimeInterval: recordLength,
                                               repeats: false) { [weak self] _ in
                self?.stopRecording()
            }
        } catch {
            delegate?.didFailDiscovering(error: .cannotStartRecord)
        }
    }
    
    func stopRecording(abortRecognize: Bool = false) {
        audioRecorder?.stop()
        audioRecorder = nil
        cutoffTimer?.invalidate()
        cutoffTimer = nil
        if !abortRecognize {
            remoteRecognize()
        } else {
            delegate?.didFailDiscovering(error: .abortedRecord)
        }
        recordingAudio = false
    }
    
    func toggleAudioRecording() {
        if !recordingAudio {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    func remoteRecognize() {
        if let data = try? Data(contentsOf: getRecordUrl()) {
            scanAudio(data: data)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getRecordUrl() -> URL {
        getDocumentsDirectory().appendingPathComponent("capture.wav")
    }
}
