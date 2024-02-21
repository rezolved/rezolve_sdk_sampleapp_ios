import UIKit
import AVFoundation
import CoreLocation
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
    private var category: RezolveSDK.Category?
    private var merchantID: String?
    private let locationManager: RZLocationManagerProtocol? = RZLocationManager()
    private var lastKnownLocation: CLLocation?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        
        setupLocationTracking()
        
        guard let scanManagerInstance = RezolveService.session?.getScanManager() else {
            return
        }
        scanManager = scanManagerInstance
        scanManager.rezolveScanResultDelegate = self
        scanManager.productResultDelegate = self
        
        DeepLinkHandler.observe { (url) in
            RezolveService.session?.triggerManager.resolve(
                url: url,
                productDelegate: self,
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
    }
    
    // Expand camera preview to container
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if case .some(let preview) = scanCameraView.layer as? AVCaptureVideoPreviewLayer {
            preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }
    }
    
    private func open(url: URL) {
        customUrl = url
        performSegue(withIdentifier: "showWebView", sender: self)
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
        } else if let categoryViewController = segue.destination as? CategoryViewController {
            categoryViewController.category = category
            categoryViewController.merchantID = merchantID
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
        
        DispatchQueue.global(qos: .background).async { [unowned self] in
            try? self.scanManager.startImageScan(scanCameraView: scanCameraView)
            self.scanManager?.startAudioScan()
        }
    }
    
    private func setupLocationTracking() {
        guard let locationManager = locationManager else {
            return
        }
        locationManager.currentLocation.bind { [weak self] (_, location) in
            guard let self = self else { return }
            self.lastKnownLocation = location
        }

        locationManager.startUpdating()
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
                self.onSspEngagementResult(engagement: result)
            case .failure(let error):
                self.onError(error: error.localizedDescription)
            }
        }
    }
}

extension ScanViewController: ProductDelegate {
    
    func showShutterView() {
    }
    
    func hideScanStaticImage() {
    }
    
    func onStartRecognizeImage() {
        progressView.isHidden = false
        statusView.text = "Identification..."
    }
    
    func onFinishRecognizeImage() {
        statusView.text = "Processing..."
    }
    
    func onInactiveEngagement(payload: RezolveCustomPayload) {
    }
    
    func onError(error: String) {
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
        self.category = category
        self.merchantID = merchantId
        performSegue(withIdentifier: "showCategory", sender: nil)
    }
    
    func onCategoryProductsResult(merchantId: String, category: RezolveSDK.Category, productsPage: PageResult<DisplayProduct>) {
        onCategoryResult(merchantId: merchantId, category: category)
    }
    
    // MARK: - SSP
    
    func onSspEngagementResult(engagement: ResolverEngagement) {
        progressView.isHidden = true
        scanningInProgress = false
        scanManager.stop()

        let notification = EngagementNotification(engagement: engagement)
        handle(engagmentNotification: notification)
    }
}
