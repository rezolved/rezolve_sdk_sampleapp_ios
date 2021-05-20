import UIKit
import AVFoundation
import CoreGraphics
import RezolveSDK

class ScanViewController: UIViewController, CameraPreviewLayer {
        
    // Heads-up display
    enum HUDState {
        case active
        case photo
        case recording
    }
    
    // Interface Builder
    @IBOutlet var scanCameraView: ScanCameraView!
    @IBOutlet weak var statusView: UILabel!
    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var shutterButton: UIButton!
    @IBOutlet weak var microphoneButton: UIButton!
    
    // Class variables
    var session: AVCaptureSession?
    private var photoResolver: PhotoRemoteResolver?
    private var audioResolver: AudioRemoteResolver?
    
    private var product: Product?
    private var sspAct: SspAct?
    private var customUrl: URL?
    private var scanningInProgress = false
    private var category: RezolveSDK.Category?
    private var merchantID: String?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        
        DeepLinkHandler.observe { (url) in
            RezolveService.session?.triggerManager.resolve(
                url: url,
                productDelegate: self,
                eventType: .touch,
                onRezolveTriggerStart: { },
                onRezolveTriggerEnd: { },
                errorCallback: { (error) in
                    debugPrint(error)
                    self.open(url: url)
                }
            )
        }
        
        NotificationsHandler.observe { (notification) in
            self.handle(engagmentNotification: notification)
        }
        
        photoResolver = PhotoRemoteResolver()
        photoResolver?.delegate = self
        audioResolver = AudioRemoteResolver()
        audioResolver?.delegate = self
        
    }
    
    func setupObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func willResignActive() {
        
        if audioResolver?.recordingAudio == true {
            audioResolver?.stopRecording(abortRecognize: true)
        }
    }
    
    // Expand camera preview to container
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func open(url: URL) {
        customUrl = url
        performSegue(withIdentifier: "showWebView", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSession() { session in
            self.photoResolver?.attatchToSession(session: session)
        }
        setupObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
        removeObserver()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let product = self.product, segue.identifier == "showProduct" {
            let productViewController = segue.destination as! ProductViewController
            productViewController.product = product
        } else if let sspAct = self.sspAct, segue.identifier == "showSspAct" {
            let sspActViewController = segue.destination as! SspActViewController
            sspActViewController.viewModel = SspActViewModel(sspAct: sspAct)
        } else if let customUrl = self.customUrl, segue.identifier == "showWebView" {
            let webViewController = segue.destination as! WebViewController
            webViewController.url = customUrl
        } else if let categoryViewController = segue.destination as? CategoryViewController {
            categoryViewController.category = category
            categoryViewController.merchantID = merchantID
        }
    }
    
    
    @IBAction func audioAction(_ sender: Any) {
        if audioResolver?.recordingAudio == false {
            displayState(state: .recording)
        }
        audioResolver?.toggleAudioRecording()
    }
    
    @IBAction func photoAction(_ sender: Any) {
        displayState(state: .photo)
        photoResolver?.capturePicture()
    }
    
    func displayState(state: HUDState) {
        switch state {
        case .active:
            shutterButton.isEnabled = true
            microphoneButton.isEnabled = true
            if #available(iOS 13.0, *) {
                let image = UIImage(systemName: "mic.circle", withConfiguration: nil)
                microphoneButton.setImage(image, for: .normal)
            }
        case .recording:
            shutterButton.isEnabled = false
            if #available(iOS 13.0, *) {
                let image = UIImage(systemName: "stop.circle", withConfiguration: nil)
                microphoneButton.setImage(image, for: .normal)
            }
            
        case .photo:
            microphoneButton.isEnabled = false
            shutterButton.isEnabled = false
        }
    }
    
    // MARK: - Private methods
    
    private func handleSspActPresentation(sspAct: SspAct) {
        switch sspAct.type {
        case .buy:
            print("Act Buy")
        case .regular, .informationPage:
            self.sspAct = sspAct
            self.performSegue(withIdentifier: "showSspAct", sender: self)
        case .unknown:
            print("Unsupported Act logic")
        }
    }
    
    private func handle(engagmentNotification: EngagementNotification) {
        if let url = engagmentNotification.customURL {
            DeepLinkHandler.handle(url: url)
        } else if let act = engagmentNotification.engagement.rezolveCustomPayload.act {
            handleSspActPresentation(sspAct: act.act)
        } else {
            print("Unsupported Engagement logic")
        }
    }
}


extension ScanViewController: CaptureLayerDelegate {
    
    func didFailDiscovering(error: CaptureError) {
        statusView.text = "No results"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.progressView.isHidden = true
        }
        displayState(state: .active)
    }
    
    func didStartDiscovering() {
        progressView.isHidden = false
        statusView.text = "Identification..."
    }
    
    func didDiscover(engagement: ResolverEngagement, eventType: RezolveEventReport.RezolveEventReportType) {
        displayState(state: .active)
        progressView.isHidden = true
        stopSession()
        let notification = EngagementNotification(engagement: engagement, eventType: eventType)
        handle(engagmentNotification: notification)
    }
}

extension ScanViewController: RezolveScanResultDelegate {
    
    func onScanResult(result: RezolveScanResult) {
        guard !scanningInProgress else {
            return
        }
        
        // Condition to match specific QR code parameter
        guard
            let urlParams = URLComponents(string: result.content)?.queryItems,
            let engagementId = urlParams.first(where: { $0.name == "engagementid" })?.value else {
                return
        }
        
        scanningInProgress = true
        progressView.isHidden = false
        RezolveService.session?.sspActManager.engagementResolver(engagementId: engagementId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                self.onSspEngagementResult(engagement: result, eventType: .qr)
            case .failure(let error):
                self.onError(error: error.localizedDescription, eventType: .qr)
            }
        }
    }
    
    func onError(error: String) {
        progressView.isHidden = true
        print(error)
    }
}

extension ScanViewController: ProductDelegate {
    
    func onStartRecognizeImage() {
        progressView.isHidden = false
        statusView.text = "Identification..."
    }
    
    func onFinishRecognizeImage() {
        statusView.text = "Processing..."
    }
    
    func onInactiveEngagement(payload: RezolveCustomPayload) {
    }
    
    func onError(error: String, eventType: RezolveEventReport.RezolveEventReportType) {
    }
    
    // MARK: - RCE
    
    func onProductResult(product: Product) {
        progressView.isHidden = true
        scanningInProgress = false
        stopSession()
        
        self.product = product
        self.performSegue(withIdentifier: "showProduct", sender: self)
    }
    
    func onCategoryResult(merchantId: String, category: RezolveSDK.Category) {
        self.category = category
        self.merchantID = merchantId
        performSegue(withIdentifier: "showCategory", sender: nil)
    }
    
    func onCategoryProductsResult(merchantId: String, category: RezolveSDK.Category, productsPage: PageResult<DisplayProduct>) {
        onCategoryResult(merchantId: merchantId, category: category)
    }
    
    // MARK: - SSP
    
    func onSspEngagementResult(engagement: ResolverEngagement, eventType: RezolveEventReport.RezolveEventReportType) {
        progressView.isHidden = true
        scanningInProgress = false
        stopSession()
        
        let notification = EngagementNotification(engagement: engagement, eventType: eventType)
        handle(engagmentNotification: notification)
    }
}
