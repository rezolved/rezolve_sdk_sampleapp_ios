import UIKit
import AVKit
import RezolveSDK

final class SspActViewController: UIViewController {
    
    // Interface Builder
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitView: UIView!
    @IBOutlet weak var progressView: UIView!
    
    // Class variables
    var viewModel: SspActViewModel!
    
    // Private variables
//    private let dataSource = SspActDataSource()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        setupTableView()
        
        viewModel.loadPage()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        viewModel.validatePage()
    }
    
    // MARK: - Private methods
    
    private func setupTableView() {
//        dataSource.delegate = self
//        tableView.delegate = self
        tableView.separatorStyle = .none
//        tableView.dataSource = dataSource
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
    
    private func selectDate(for dateField: Page.Element.DateField, at indexPath: IndexPath) {
        dateField.value = Date()
        self.reloadCell(at: indexPath)
    }
    
    private func selectOption(for select: Page.Element.Select, at indexPath: IndexPath) {
        select.value = select.options[0]
        self.reloadCell(at: indexPath)
    }
    
    // MARK: - IB methods
    
    @IBAction func submitAct(_ sender: Any) {
        guard let manager = RezolveService.session?.sspActManager else {
            return
        }
        
        progressView.isHidden = false
        viewModel.submit(
            sspActManager: manager,
            location: nil
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let summaryViewController = segue.destination as? SspActSubmissionSummaryViewController {
            summaryViewController.sspAct = viewModel.sspAct
            summaryViewController.page = viewModel.page
        }
    }
}

//extension SspActViewController: SspActDataSource.Delegate {
//
//    func sspActTermsCell(_ sspActTermsCell: SspActTermsCell, didInteractWith URL: URL) {
//    }
//
//    func pageElementTextFieldCell(_ cell: PageElementTextFieldCell, didChangeText text: String, for textField: Page.Element.TextField) {
//        textField.value = text
//    }
//
//    func pageElementTextFieldCell(_ cell: PageElementTextFieldCell, didBeginEditing text: String, for textField: Page.Element.TextField) {
//        guard let indexPath = tableView.indexPath(for: cell) else {
//            return
//        }
//        tableView.safeScrollToRow(at: indexPath, at: .bottom, animated: true)
//    }
//
//    func pageElementTextFieldCell(_ cell: PageElementTextFieldCell, didEndEditing text: String, for textField: Page.Element.TextField) {
//        reloadCell(cell: cell)
//    }
//
//    func pageElementVideoCell(_ cell: PageElementVideoCell, didRequestForVideo url: URL, completion: @escaping (Video) -> Void) {
//        videoRepository.video(url: url, completion: completion)
//    }
//
//    func pageElementVideoCell(_ cell: PageElementVideoCell, didTapFullScreen player: AVPlayer) {
//        let playerViewController = AVPlayerViewController()
//        playerViewController.player = player
//        present(playerViewController, animated: true, completion: nil)
//    }
//
//    func pageElementImageCellDidLoadImage(_ cell: PageElementImageCell) {
//        reloadCell(cell: cell)
//    }
//}

extension SspActViewController: SspActViewModelDelegate {
    func display(items: [Page.Element]) {
//        dataSource.items = items
        tableView.reloadData()
    }
    
    func enableSubmitView(isEnabled: Bool) {
        submitView.isHidden = !isEnabled
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

//extension SspActViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let item = dataSource[indexPath]
//        return item.cellHeight
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let item = dataSource[indexPath]
//        switch item {
//        case .description, .images, .terms:
//            break
//        case .pageElement(let pageElement):
//            switch pageElement {
//            case .text, .divider, .image, .textField, .video:
//                break
//            case .dateField(let dateField):
//                selectDate(for: dateField, at: indexPath)
//            case .select(let select):
//                selectOption(for: select, at: indexPath)
//            }
//        }
//    }
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.selectionStyle = .none
//    }
//
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if let videoCell = cell as? PageElementVideoCell {
//            videoCell.stop()
//        }
//    }
//}
