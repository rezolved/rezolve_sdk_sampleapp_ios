//
//  ScanViewController.swift
//  Example
//
//  Created by Jakub Bogacki on 16/04/2019.
//  Copyright © 2019 Jakub Bogacki. All rights reserved.
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
        
        scanManager.startVideoScan(scanCameraView: scanCameraView)
        scanManager.startAudioScan()
    }

    func onStartRecognizeImage() {
        UIUpdate { [weak self] in
            self?.progressView.isHidden = false
            self?.statusView.text = "Identification..."
        }
        print("onStartRecognizeImage")
    }

    func onFinishRecognizeImage() {
        print("onFinishRecognizeImage")
        statusView.text = "Processing..."
    }

    func onProductResult(product: Product) {
        UIUpdate { [weak self] in
            self?.progressView.isHidden = true
        }
       
        scanManager.stop()
        self.product = product
        self.performSegue(withIdentifier: "showProduct", sender: self)
    }
    
    // MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let product = self.product, segue.identifier == "showProduct" {
            let productViewController = segue.destination as! ProductViewController
            productViewController.scannedProduct = product
            self.product = nil
        }
    }

}

// MARK: - ProductDelegate

extension ScanViewController: ProductDelegate {
    
    func onCategoryResult(merchantId: String, category: RezolveCategory) {
        
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
