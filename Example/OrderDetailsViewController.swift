//
//  OrderDetailsViewController.swift
//  Example
//
//  Created by Jakub Bogacki on 23/04/2019.
//  Copyright © 2019 Jakub Bogacki. All rights reserved.
//

import UIKit
import RezolveSDK

class OrderDetailsViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    // MARK: - Private properties

    private lazy var rezolveSession = (UIApplication.shared.delegate as! AppDelegate).rezolveSession!
    
    // MARK: - Public properties
    
    var orderId: String!
    var product: Product!
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        rezolveSession.userActivityManager.getOrders { (result) in
//            switch result {
//            case .success(let orders):
//                let order = orders!.first(where: { (order) -> Bool in order.orderId == self.orderId})
//                self.showDetails(order!)
//            case .failure(let error):
//                print("\(error)")
//            }
//        }
    }
    
//    func showDetails(_ order: HistoryTransactionDetails) {
//        statusLabel.text = order.status
//        orderIdLabel.text = order.orderId
//        productNameLabel.text = product.title
//        totalLabel.text = String(order.price.finalPrice)
//    }
    
    // MARK: - User Interactions
    
    @IBAction func continueShoppingClick(_ sender: Any) {
        navigationController!.popToViewController(navigationController!.viewControllers[0], animated: true)
    }
}
