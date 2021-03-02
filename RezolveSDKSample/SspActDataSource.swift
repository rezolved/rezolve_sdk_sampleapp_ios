import UIKit
import RezolveSDK

final class SspActDataSource: NSObject, UITableViewDataSource {
    
    typealias Delegate = PageElementTextFieldCellDelegate & PageElementVideoCellDelegate & PageElementImageCellDelegate
    
    weak var delegate: Delegate?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    }
}
