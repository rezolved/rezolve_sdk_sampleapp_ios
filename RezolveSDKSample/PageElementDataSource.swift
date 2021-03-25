import RezolveSDK

final class PageElementDataSource: NSObject, UITableViewDataSource {
    
    var items = [Page.Element]()
    
    typealias Delegate = TextFieldCellDelegate
    
    weak var delegate: Delegate?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        
        switch item {
        case .dateField(let dateField):
            let cell = tableView.dequeueReusableCell(withIdentifier: "DateFieldCell", for: indexPath) as! DateFieldCell
            cell.configure(with: dateField)
            return cell
        case .text(let text):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextCell
            cell.configure(with: text)
            return cell
        case .divider:
            return tableView.dequeueReusableCell(withIdentifier: "DividerCell", for: indexPath)
        case .image(let image):
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageCell
            cell.configure(with: image.url)
            return cell
        case .video:
            return tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
        case .select(let select):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCell", for: indexPath) as! SelectCell
            cell.configure(with: select)
            return cell
        case .textField(let textField):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
            cell.delegate = delegate
            cell.configure(with: textField)
            return cell
        }
    }
}
