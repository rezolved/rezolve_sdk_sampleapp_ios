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

class ScanViewController: UIViewController, ProductDelegate, RezolveScanResultDelegate {
    @IBOutlet private var scanCameraView: ScanCameraView!
    @IBOutlet weak var statusView: UILabel!
    @IBOutlet weak var progressView: UIView!
    private var scanManager: ScanManager!
    private var product: Product?
    private lazy var session = (UIApplication.shared.delegate as! AppDelegate).session!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scanManager = session.getScanManager(environment: ResolverEnvironment.productionResolver)
        scanManager.rezolveScanResultDelegate = self
        scanManager.productResultDelegate = self
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
            self.product = nil
        }
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
        scanManager.startVideoScan(scanCameraView: scanCameraView) { (error) in
            print(error)
        }
        scanManager.startAudioScan(errorHandler: { (error) in
            print(error)
        })
    }

    func onScanResult(result: RezolveScanResult) {
        
    }

    func onError(error: String) {
        print(error)
        progressView.isHidden = true
    }

    func onStartRecognizeImage() {
        progressView.isHidden = false
        statusView.text = "Identification..."
        print("onStartRecognizeImage")
    }

    func onFinishRecognizeImage() {
        print("onFinishRecognizeImage")
        statusView.text = "Processing..."
    }

    func onProductResult(product: Product) {
        progressView.isHidden = true
        scanManager.stop()
        self.product = product
        self.performSegue(withIdentifier: "showProduct", sender: self)
    }

    func onCategoryResult(merchantId: String, category: RezolveSDK.Category) {

    }

    func onCategoryProductsResult(merchantId: String, category: RezolveSDK.Category, productsPage: PageResult<DisplayProduct>) {

    }
}
