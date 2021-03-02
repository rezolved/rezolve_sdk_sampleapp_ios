import UIKit
import Reusable
import RezolveSDK

final class SspActDataSource: NSObject, UITableViewDataSource {
    
    typealias Delegate = PageElementTextFieldCellDelegate & PageElementVideoCellDelegate & PageElementImageCellDelegate
    
    weak var delegate: Delegate?
    
    var items: [SspActItem] = []
    
    subscript(indexPath: IndexPath) -> SspActItem {
        items[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        switch item {
        case .images(let imageURLs):
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SspActImageCell.self)
            cell.setupImageCell(from: imageURLs)
            return cell
        case .description(let sspAct):
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SspActDescriptionCell.self)
            cell.setupLabels(sspAct: sspAct)
            return cell
        case .pageElement(let pageElement):
            return cell(tableView: tableView, indexPath: indexPath, for: pageElement)
        }
    }
    
    private func cell(tableView: UITableView, indexPath: IndexPath, for pageElement: Page.Element) -> UITableViewCell {
        switch pageElement {
        case .text(let text):
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: PageElementTextCell.self)
            cell.configure(with: text)
            return cell
        case .divider:
            return tableView.dequeueReusableCell(for: indexPath, cellType: PageElementDividerCell.self)
        case .image(let image):
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: PageElementImageCell.self)
            cell.delegate = delegate
            cell.configure(with: image)
            return cell
        case .video(let url):
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: PageElementVideoCell.self)
            cell.delegate = delegate
            cell.configure(with: url)
            return cell
        case .textField(let textField):
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: PageElementTextFieldCell.self)
            cell.delegate = delegate
            cell.configure(with: textField)
            return cell
        case .dateField(let dateField):
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: PageElementSelectionCell.self)
            cell.configure(with: dateField)
            return cell
        case .select(let select):
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: PageElementSelectionCell.self)
            cell.configure(with: select)
            return cell
        }
    }
}

extension SspActDescriptionCell: Reusable { }
extension SspActImageCell: Reusable { }

extension SspActItem {
    
    var cellHeight: CGFloat {
        switch self {
        case .images:
            return 325
        case .description, .pageElement:
            return UITableView.automaticDimension
        }
    }
}

extension Page.Element.DateField: PageElementSelectionCellModelType {
    var headerText: String? {
        text
    }
    
    var placeholder: String {
        "Select a Date"
    }
    
    var valueText: String? {
        guard let date = value else {
            return nil
        }
        return AbbreviatedMonthDateFormatter.getMonthWithoutDotDateText(currentDate: date)
    }
}

extension Page.Element.Select: PageElementSelectionCellModelType {
    var headerText: String? {
        text
    }
    
    var placeholder: String {
        "Select an Option"
    }
    
    var valueText: String? {
        value?.description
    }
}
