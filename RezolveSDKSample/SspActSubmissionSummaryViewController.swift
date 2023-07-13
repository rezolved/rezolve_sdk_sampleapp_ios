import UIKit
import RezolveSDK

final class SspActSubmissionSummaryViewController: UIViewController {
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var sspAct: SspAct?
    var page: Page?
    
    var items: [SspActAnswerCell.Item] {
        guard let page = page else {
            return []
        }
        return page.elements.compactMap(item(from:))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ACT submitted"
        
        label.text = sspAct?.name
        tableView.dataSource = self
    }
    
    func item(from element: Page.Element) -> SspActAnswerCell.Item? {
        switch element {
        case .dateField(let dateField):
            return SspActAnswerCell.Item(
                question: dateField.text ?? "",
                answer: dateField.value.map(SspActSubmissionSummaryViewController.dateFormatter.string(from:)) ?? ""
            )
        case .select(let select):
            return SspActAnswerCell.Item(
                question: select.text ?? "",
                answer: select.value?.description ?? ""
            )
        case .textField(let textField):
            return SspActAnswerCell.Item(
                question: textField.text ?? "",
                answer: textField.value ?? ""
            )
        case .text, .divider, .image, .video:
            return nil
        default:
            return nil
        }
    }
}

extension SspActSubmissionSummaryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SspActAnswerCell", for: indexPath) as! SspActAnswerCell
        cell.item = items[indexPath.row]
        return cell
    }
}

final class SspActAnswerCell: UITableViewCell {
    
    struct Item {
        let question: String
        let answer: String
    }
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    var item: Item? {
        didSet {
            questionLabel.text = item?.question
            answerLabel.text = item?.answer
        }
    }
}
