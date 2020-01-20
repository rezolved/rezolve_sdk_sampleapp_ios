//
//  ScanViewController.swift
//  Example
//
//  Created by Jakub Bogacki on 16/04/2019.
//  Copyright © 2019 Rezolve. All rights reserved.
//

import UIKit
import RezolveSDK
import AVFoundation

class ScanViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet private var scanCameraView: ScanCameraView!
    @IBOutlet weak var statusView: UILabel!
    @IBOutlet weak var progressView: UIView!
    
    // MARK: - Private properties
    
    private var scanManager: ScanManager!
    private var product: Product?
    private var categoryPresantationData: CategoryPresentationData?
    private lazy var rezolveSession = (UIApplication.shared.delegate as! AppDelegate).rezolveSession!
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openSession()
        registerDelegates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        askPermission()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scanManager.stop()
        progressView.isHidden = true
    }
    
    // MARK: - ScanManager methods
    
    private func openSession() {
        self.scanManager = rezolveSession.getScanManager(env: Config.env.rawValue)
    }
    
    private func registerDelegates() {
        self.scanManager.productResultDelegate = self
        self.scanManager.rezolveScanResultDelegate = self
        self.scanManager.autoDetectManagerDelegate = self
    }
    
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
    
    func startScanning() {
        if Platform.isSimulator {
            return
        }
        
        try? scanManager.startVideoScan(scanCameraView: scanCameraView)
        try? scanManager.startAudioScan()
    }
    
    func onStartRecognizeImage() {
        UIUpdate { [weak self] in
            self?.progressView.isHidden = false
            self?.statusView.text = Constant.StatusText.identification
        }
        print("onStartRecognizeImage")
    }
    
    func onFinishRecognizeImage() {
        print("onFinishRecognizeImage")
        statusView.text = Constant.StatusText.processing
    }
    
    func onProductResult(product: Product) {
        UIUpdate { [weak self] in
            self?.progressView.isHidden = true
        }
        
        scanManager.stop()
        self.product = product
        self.performSegue(withIdentifier: Constant.SegueIdentifier.product, sender: self)
    }
    
    // MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        configure(destination: segue.destination, identifier: segue.identifier)
    }
    
    private func configure(destination viewController: UIViewController, identifier: String?) {
        switch identifier {
        case Constant.SegueIdentifier.product:
            configure(product: viewController)
        case Constant.SegueIdentifier.category:
            configure(category: viewController)
        default: return
        }
    }
    
    private func configure(product viewController: UIViewController) {
        guard let productViewController = viewController as? ProductViewController else { return }
        productViewController.scannedProduct = product
        self.product = nil
    }
    
    private func configure(category viewController: UIViewController) {
        guard
            let categoryVC = viewController as? CategoryViewController,
            let categoryPresantationData = categoryPresantationData
            else {
                return
        }
        categoryVC.set(category: categoryPresantationData)
        self.categoryPresantationData = nil
    }
}

// MARK: - ProductDelegate

extension ScanViewController: ProductDelegate {
    
    func onCategoryResult(merchantId: String, category: RezolveCategory) {
        let loader = ProductCategoryLoader(merchantId: merchantId, category: category)
        loader.loadCategoryPresentationData(with: rezolveSession) { categoryPresantationData in
            self.categoryPresantationData = categoryPresantationData
            self.performSegue(withIdentifier: Constant.SegueIdentifier.category, sender: self)
        }
        
    }
    
    func onCategoryProductsResult(merchantId: String, category: RezolveCategory, productsPage: PageResult<DisplayProduct>) {
        
    }
}

// MARK: - RezolveScanResultDelegate

extension ScanViewController: RezolveScanResultDelegate {
    
    func onScanResult(result: RezolveScanResult) {
        
    }
    
    func onError(error: String) {
        print(error)
        progressView.isHidden = true
    }
    
}

// MARK: - AutoDetectManagerDelegate

extension ScanViewController: AutoDetectManagerDelegate {
    
    func onAutoDetectStopListening(resolved: [AutoDetectResult]) {
        
    }
    
    func onAutoDetectError(error: String) {
        print(error)
        progressView.isHidden = true
    }
    
}

// MARK: - Constants

extension ScanViewController {
    enum Constant {
        enum SegueIdentifier {
            static let product = "showProduct"
            static let category = "showCategory"
        }
        
        enum StatusText {
            static let processing = "Processing..."
            static let identification = "Identification..."
        }
    }
}
