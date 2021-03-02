import UIKit
import AVKit
import RezolveSDK

class SspActViewController: UIViewController {
    
    // Interface Builder
    @IBOutlet weak var tableView: UITableView!
    
    // Class variables
    var viewModel: SspActViewModel!
    
    // Private variables
    private let dataSource = SspActDataSource()
    private let datePicker = DatePicker()
    private let optionPicker = PageElementOptionPicker()
    private let videoRepository = VideoRepository()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        
        setupTableView()
    }
    
    // MARK: - Private methods
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.separatorStyle = .none
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
        datePicker.pick(for: dateField) { [weak self, weak dateField] (date) in
            guard let self = self, let dateField = dateField else {
                return
            }
            dateField.value = date
            self.reloadCell(at: indexPath)
        }
    }
    
    private func selectOption(for select: Page.Element.Select, at indexPath: IndexPath) {
        optionPicker.pick(for: select) { [weak select, weak self] (option) in
            guard let select = select, let self = self else {
                return
            }
            select.value = option
            self.reloadCell(at: indexPath)
        }
    }
}

extension SspActViewController: SspActDataSource.Delegate {
    
    func pageElementTextFieldCell(_ cell: PageElementTextFieldCell, didChangeText text: String, for textField: Page.Element.TextField) {
        textField.value = text
    }
    
    func pageElementTextFieldCell(_ cell: PageElementTextFieldCell, didBeginEditing text: String, for textField: Page.Element.TextField) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        tableView.safeScrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func pageElementTextFieldCell(_ cell: PageElementTextFieldCell, didEndEditing text: String, for textField: Page.Element.TextField) {
        reloadCell(cell: cell)
    }
    
    func pageElementVideoCell(_ cell: PageElementVideoCell, didRequestForVideo url: URL, completion: @escaping (Video) -> Void) {
        videoRepository.video(url: url, completion: completion)
    }
    
    func pageElementVideoCell(_ cell: PageElementVideoCell, didTapFullScreen player: AVPlayer) {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true, completion: nil)
    }
    
    func pageElementImageCellDidLoadImage(_ cell: PageElementImageCell) {
        reloadCell(cell: cell)
    }
}

extension SspActViewController: SspActViewModelDelegate {
    func display(items: [SspActItem]) {
        dataSource.items = items
        tableView.reloadData()
    }
}

extension SspActViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = dataSource[indexPath]
        return item.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSource[indexPath]
        switch item {
        case .description, .images:
            break
        case .pageElement(let pageElement):
            switch pageElement {
            case .text, .divider, .image, .textField, .video:
                break
            case .dateField(let dateField):
                selectDate(for: dateField, at: indexPath)
            case .select(let select):
                selectOption(for: select, at: indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let videoCell = cell as? PageElementVideoCell {
            videoCell.stop()
        }
    }
}
