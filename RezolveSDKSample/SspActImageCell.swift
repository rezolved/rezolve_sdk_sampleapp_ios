import Foundation
import RezolveSDK

final class SspActImageCell: UITableViewCell {
    
    // MARK: - Properties / Views
    
    private var imagesUrls: [URL] = []
    
    private lazy var imageSliderView: ImageSliderView = {
        let imageSliderView = imageSlider(withImagesFrom: imagesUrls)
        imageSliderView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageSliderView)
        
        return imageSliderView
    }()
    
    // MARK: - UI Configuration/Management
    
    func setupImageCell(from imagesUrls: [URL]) {
        self.imagesUrls = imagesUrls
        activateImageSliderViewConstraints()
    }
    
    private func activateImageSliderViewConstraints() {
        NSLayoutConstraint.activate(
            [
                imageSliderView.topAnchor.constraint(equalTo: topAnchor),
                imageSliderView.leadingAnchor.constraint(equalTo: leadingAnchor),
                imageSliderView.trailingAnchor.constraint(equalTo: trailingAnchor),
                imageSliderView.heightAnchor.constraint(equalToConstant: 325.0),
            ]
        )
    }
    
    private func imageSlider(withImagesFrom urls: [URL]) -> ImageSliderView {
         let imageViews = urls.map { (url) -> UIImageView in
             let imageView = UIImageView()

             imageView.kf.setImage(
                 with: url,
                 placeholder: UIImage(named: "placeholder"),
                 options: [.transition(.fade(UIImageView.AnimationConsts.fadeTimeInterval))]
             )
             return imageView
         }
 
         return ImageSliderView(imageViews: imageViews)
     }
}
