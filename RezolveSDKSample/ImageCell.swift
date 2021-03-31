import Kingfisher

final class ImageCell: UITableViewCell {
    @IBOutlet weak var pageElementImageView: UIImageView!
    
    func configure(with url: URL) {
        pageElementImageView.kf.setImage(with: url)
    }
}
