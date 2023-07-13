import UIKit
import RezolveSDKLite

class OrderDetailsViewController: UIViewController {
    
    // Interface Builder
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    // Class variables
    var orderId: String!
    var product: Product!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RezolveService.session?.userActivityManager.getOrders { [weak self] result in
            switch result {
            case .success(let orders):
                guard let order = orders.first(where: { order -> Bool in
                    order.orderId == self?.orderId
                }) else {
                    return
                }
                self?.showDetails(order)
                
            case .failure(let error):
                print("Get orders error -> \(error)")
            }
        }
    }
    
    // MARK: - Private methods
    
    private func showDetails(_ order: HistoryTransactionDetails) {
        statusLabel.text = order.status
        orderIdLabel.text = order.orderId
        productNameLabel.text = product.title
        totalLabel.text = String("$\(order.price.finalPrice.rounded(toPlaces: 2))")
    }
    
    // MARK: - Actions
    
    @IBAction func continueShoppingClick(_ sender: Any) {
        guard let scanViewController = navigationController?.viewControllers.first as? ScanViewController else {
            return
        }
        navigationController?.popToViewController(scanViewController, animated: true)
    }
}
