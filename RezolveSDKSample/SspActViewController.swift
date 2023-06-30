import UIKit
import AVKit
import RezolveSDKLite

final class SspActViewController: UIViewController {
    
    // Interface Builder
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitView: SlideToActionView!
    @IBOutlet weak var progressView: UIView!
    
    // Class variables
    var viewModel: SspActViewModel!
    
    // Private variables
    private let dataSource = PageElementDataSource()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        setupTableView()
        
        viewModel.loadPage()
        
        submitView.isAddCart = false
        submitView.delegate = self
        submitView.isHidden = viewModel.sspAct.isInformationPage == true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        viewModel.validatePage()
    }
    
    // MARK: - Private methods
    
    private func setupTableView() {
        dataSource.delegate = self
        tableView.delegate = self
        tableView.dataSource = dataSource
    }
    
    private func reloadCell(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        reloadCell(at: indexPath)
    }
    
    private func reloadCell(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
        viewModel.validatePage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let summaryViewController = segue.destination as? SspActSubmissionSummaryViewController {
            summaryViewController.sspAct = viewModel.sspAct
            summaryViewController.page = viewModel.page
        }
    }
}

extension SspActViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSource.items[indexPath.row]
        switch item {
        case .dateField(let dateField):
            dateField.value = Date()
        case .select(let select):
            select.value = select.options.first
        case .video(let url):
            UIApplication.shared.open(url)
        case .text, .divider, .image, .textField:
            break
        default:
            break
        }
        
        reloadCell(at: indexPath)
    }
}

extension SspActViewController: SspActViewModelDelegate {
    func display(items: [Page.Element]) {
        dataSource.items = items
        tableView.reloadData()
    }
    
    func enableSubmitView(isEnabled: Bool) {
        submitView.isEnableSliderCart(isEnabled)
    }
    
    func actSubmissionFailed(with error: RezolveError) {
        progressView.isHidden = true
        print(error)
    }
    
    func actSubmissionSucceed() {
        progressView.isHidden = true
        performSegue(withIdentifier: "showSubmissionSummary", sender: nil)
    }
}

extension SspActViewController: PageElementDataSource.Delegate {
    func textFieldCell(_ cell: TextFieldCell, didChangeText text: String, model: Page.Element.TextField) {
        model.value = text
        reloadCell(cell: cell)
    }
}

extension SspActViewController: SlideToActionViewDelegate {
    func slideToPayEndSlider() {
        guard let manager = RezolveService.session?.sspActManager else {
            return
        }
        
        progressView.isHidden = false
        viewModel.submit(
            sspActManager: manager,
            location: nil
        )
    }
}
