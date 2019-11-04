//
//  OrderDetailsViewController.swift
//  Example
//
//  Created by Jakub Bogacki on 23/04/2019.
//  Copyright © 2019 Rezolve. All rights reserved.
//

import UIKit
import RezolveSDK

class OrderDetailsViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    
    // MARK: - Private properties

    private lazy var rezolveSession = (UIApplication.shared.delegate as! AppDelegate).rezolveSession!
    
    // MARK: - Public properties
    
    var orderId: String!
    var product: Product!
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.isHidden = false
        
        // Waiting for last transaction processing on server
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: { [weak self] in
            self?.getOrders()
        })
        
    }
    
    // MARK: - Helpers methods
    
    private func getOrders() {
        rezolveSession.userActivityManager.getOrders(callback: { [weak self] transactions in
            for order in transactions {
                if order.orderId == self?.orderId {
                    self?.progressView.isHidden = true
                    self?.showDetails(order)
                }
            }
            
            }, errorCallback: { error in
                print(error)
        })
    }
    
    private func showDetails(_ order: HistoryTransaction) {
        statusLabel.text = order.status
        orderIdLabel.text = order.orderId
        productNameLabel.text = product.title
        totalLabel.text = String(order.finalPrice.finalPrice.asAppCurrency)
    }
    
    // MARK: - User Interactions
    
    @IBAction func continueShoppingClick(_ sender: Any) {
        navigationController!.popToViewController(navigationController!.viewControllers[0], animated: true)
    }
}
