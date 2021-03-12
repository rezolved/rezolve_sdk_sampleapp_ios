import UIKit
import AVFoundation
import RezolveSDK

class ScanViewController: UIViewController {
    
    // Interface Builder
    @IBOutlet private var scanCameraView: ScanCameraView!
    @IBOutlet weak var statusView: UILabel!
    @IBOutlet weak var progressView: UIView!
    
    // Class variables
    private var scanManager: ScanManager!
    private var product: Product?
    private var sspAct: SspAct?
    private var customUrl: URL?
    private var scanningInProgress = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        
        guard let scanManagerInstance = RezolveService.session?.getScanManager() else {
            return
        }
        scanManager = scanManagerInstance
        scanManager.rezolveScanResultDelegate = self
        scanManager.productResultDelegate = self
    }
    
    // Expand camera preview to container
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if case .some(let preview) = scanCameraView.layer as? AVCaptureVideoPreviewLayer {
            preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        askPermission()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scanManager.stop()
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
        }
    }
    
    // MARK: - Private methods
    
    private func askPermission() {
        if Platform.isSimulator {
            return
        }
        
        let permissionFor = { (mediaType: AVMediaType, next: @escaping ((Bool) -> Void)) in
            AVCaptureDevice.requestAccess(for: mediaType, completionHandler: next)
        }
        
        permissionFor(AVMediaType.video as AVMediaType) { allowedVideo in
            permissionFor(AVMediaType.audio as AVMediaType) { allowedAudio in
                DispatchQueue.main.async {
                    self.startScanning()
                }
            }
        }
    }
    
    private func startScanning() {
        if Platform.isSimulator {
            return
        }
        
        try? scanManager.startVideoScan(scanCameraView: scanCameraView)
        try? scanManager?.startAudioScan()
    }
    
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
        scanManager.stop()
        
        self.product = product
        self.performSegue(withIdentifier: "showProduct", sender: self)
    }
    
    func onCategoryResult(merchantId: String, category: RezolveSDK.Category) {
    }
    
    func onCategoryProductsResult(merchantId: String, category: RezolveSDK.Category, productsPage: PageResult<DisplayProduct>) {
    }
    
    // MARK: - SSP
    
    func onSspEngagementResult(engagement: ResolverEngagement, eventType: RezolveEventReport.RezolveEventReportType) {
        progressView.isHidden = true
        scanningInProgress = false
        scanManager.stop()
        
        let notification = EngagementNotification(engagement: engagement, eventType: eventType)
        
        if let url = notification.customURL {
            self.customUrl = url
            self.performSegue(withIdentifier: "showWebView", sender: self)
        } else if let act = notification.engagement.rezolveCustomPayload.act {
            handleSspActPresentation(sspAct: act.act)
        } else {
            print("Unsupported Engagement logic")
        }
    }
}
