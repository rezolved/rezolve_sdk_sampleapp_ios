import UIKit
import RezolveSDK

class SspActViewController: UIViewController {
    
    // Interface Builder
    @IBOutlet weak var tableView: UITableView!
    
    // Class variables
    var viewModel: SspActViewModel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    // MARK: - Private methods
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
}

extension SspActViewController: UITableViewDelegate {
}
