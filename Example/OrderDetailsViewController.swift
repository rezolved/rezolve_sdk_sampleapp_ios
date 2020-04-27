//
//  OrderDetailsViewController.swift
//  Example
//
//  Modified by Dennis Koluris on 27/04/2020.
//  Copyright © 2019 Jakub Bogacki. All rights reserved.
//

import UIKit
import RezolveSDK

class OrderDetailsViewController: UIViewController {
    
    // Interface Builder
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    // Class variables
    private lazy var session = (UIApplication.shared.delegate as! AppDelegate).session!
    var orderId: String!
    var product: Product!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session.userActivityManager.getOrders { (result) in
            switch result {
            case .success(let orders):
                let order = orders.first(where: { (order) -> Bool in order.orderId == self.orderId})
                self.showDetails(order!)
            case .failure(let error):
                print("\(error)")
            }
        }
    }
    
    func showDetails(_ order: HistoryTransactionDetails) {
        statusLabel.text = order.status
        orderIdLabel.text = order.orderId
        productNameLabel.text = product.title
        totalLabel.text = String("$\(order.price.finalPrice.rounded(toPlaces: 2))")
    }
    
    @IBAction func continueShoppingClick(_ sender: Any) {
        navigationController!.popToViewController(navigationController!.viewControllers[0], animated: true)
    }
}
