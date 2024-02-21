import Kingfisher

final class ImageCell: UITableViewCell {
    
    @IBOutlet weak var pageElementImageView: UIImageView!
    @IBOutlet weak var pageElementImageViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: CellDelegate?
    
    func configure(with url: URL) {
        pageElementImageView.kf.setImage(with: url) { image, error, cacheType, imageURL in
            if let width = image?.size.width, let height = image?.size.height {
                let ratio = UIScreen.main.bounds.width / width
                let newHeight = height * ratio
                self.pageElementImageViewHeightConstraint.constant = newHeight
                self.delegate?.imageCell(self)
            }
        }
    }
}
