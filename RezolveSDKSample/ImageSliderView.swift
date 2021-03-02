import UIKit

final class ImageSliderView: UIView {
    private let imageViews: [UIImageView]
    
    private var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.hidesForSinglePage = false
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        return pageControl
    }()
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        scrollView.isUserInteractionEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private var noImageDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.text = "No main image"
        label.font = UIFont(name: "OpenSans-Bold", size: 20.0)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    init(imageViews: [UIImageView]) {
        self.imageViews = imageViews
        
        super.init(frame: CGRect.zero)
        
        setupViews()
        activateConstraints()
        feedScrollViewWithImageViews(imageViews)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    private func setupViews() {
        scrollView.delegate = self
        pageControl.numberOfPages = imageViews.count
        
        addSubview(scrollView)
        insertSubview(pageControl, aboveSubview: scrollView)
        if imageViews.isEmpty {
            insertSubview(noImageDescriptionLabel, aboveSubview: scrollView)
            activateNoImageDescriptionLabelConstraints()
        }
    }
    
    func activateConstraints() {
        NSLayoutConstraint.activate(
            [
                scrollView.topAnchor.constraint(equalTo: self.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                
                pageControl.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                pageControl.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            ]
        )
    }
    
    private func activateNoImageDescriptionLabelConstraints() {
        noImageDescriptionLabel.isHidden = false
        NSLayoutConstraint.activate(
            [
                noImageDescriptionLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                noImageDescriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                noImageDescriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            ]
        )
    }
    
    // MARK: Helpers
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for (index, imageView) in scrollView.subviews.enumerated() {
            imageView.frame = CGRect(
                x: CGFloat(index) * bounds.width,
                y: 0.0,
                width: bounds.width,
                height: bounds.height - pageControl.bounds.height
            )
        }
        
        scrollView.contentSize = CGSize(
            width: CGFloat(imageViews.count) * bounds.width,
            height: bounds.height - pageControl.bounds.height
        )
    }
    
    private func feedScrollViewWithImageViews(_ imageViews: [UIImageView]) {
        imageViews.forEach { scrollView.addSubview($0.normalizedForImageSlider) }
    }
}

extension ImageSliderView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(page)
    }
}

private extension UIImageView {
    var normalizedForImageSlider: UIImageView {
        let imageView = self
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit

        return imageView
    }
}
