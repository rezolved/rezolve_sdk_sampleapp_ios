import UIKit

final class SlideToActionView: UIView {
    
    @IBOutlet weak var slider: UIView!
    
    @IBOutlet weak var sliderTrigger: UIImageView!
    @IBOutlet weak var addToCartView: UIView!
    @IBOutlet weak var cornerAddCartView: UIView!
    @IBOutlet weak var addCartButton: UIButton!
    @IBOutlet weak var textSlideToPayLabel: UILabel!
    @IBOutlet weak var disableSliderView: UIView!
    @IBOutlet weak var disableAddCart: UIView!
    
    @IBOutlet weak var sliderToPayConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingSliderConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingSliderConstraint: NSLayoutConstraint!
    
    weak var delegate: SlideToActionViewDelegate?
    
    var touchEnding = false
    var sliderTriggerBeganPoint: CGPoint!
    var isAddCart = true {
        didSet {
            showHiddenAddCart()
        }
    }
    
    // MARK: - Init

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        if let view = UINib(nibName: "SlideToActionView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: topAnchor),
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }
        
        slider.layer.cornerRadius = 20
        sliderTrigger.isUserInteractionEnabled = true
        cornerAddCartView.layer.cornerRadius = cornerAddCartView.frame.height / 2
        sliderTriggerBeganPoint = sliderTrigger.center
    }
    
    // MARK: - UI Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if touchEnding {
            return
        }
        
        if touches.first?.view == sliderTrigger {
            delegate?.slideToPayBeginTouch()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if touchEnding {
            return
        }
        
        guard
            let firstTouch = touches.first,
            firstTouch.view == sliderTrigger
        else {
            return
        }
        
        let position = firstTouch.location(in: self)
        
        if isAddCart {
            sliderTrigger.center.x = position.x - sliderTrigger.frame.width - sliderTrigger.frame.width / 1.5
        } else {
            sliderTrigger.center.x = position.x - sliderTrigger.frame.width
        }
        
        checkLimits(flot: sliderTrigger.center.x + sliderTrigger!.frame.width, touches: touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if touches.first?.view == sliderTrigger {
            delegate?.slideToPayEndTouch()
        }
        
        reset()
    }
    
    // MARK: - UI Configuration/Management
    
    func reset() {
        UIView.animate(withDuration: 0.5) {
            self.sliderTrigger.center.x = self.sliderTriggerBeganPoint.x
            self.touchEnding = false
        }
    }
    
    func isEnableAddCart(_ isEnable: Bool) {
        disableAddCart.isHidden = isEnable
    }
    
    func isEnableSliderCart(_ isEnable: Bool) {
        disableSliderView.isHidden = isEnable
    }
    
    private func showHiddenAddCart() {
        if isAddCart {
            addToCartView.isHidden = false
            sliderToPayConstraint.constant = 70
            trailingSliderConstraint.constant = 15
            leadingSliderConstraint.constant = 15
        } else {
            addToCartView.isHidden = true
            sliderToPayConstraint.constant = 0
            trailingSliderConstraint.constant = 45
            leadingSliderConstraint.constant = 45
        }
        
        setNeedsUpdateConstraints()
    }
    
    func checkLimits(flot: CGFloat, touches: Set<UITouch>, with event: UIEvent?) {
        let halfWidth = sliderTrigger.frame.width / 2
        let max = slider.bounds.maxX + halfWidth
        if flot > max {
            sliderTrigger.center.x = slider.bounds.maxX - halfWidth
            touchEnding = true
            delegate?.slideToPayEndSlider()
        }
        
        if sliderTrigger.center.x <= sliderTriggerBeganPoint.x {
            sliderTrigger.center.x = sliderTriggerBeganPoint.x
        }
    }
    
    // MARK: - Actions
    
    @IBAction func addToCartButtonClick(_ sender: UIButton) {
        delegate?.slideAddToCartButtonClick()
    }
}

protocol SlideToActionViewDelegate: class {
    func slideToPayBeginTouch()
    func slideToPayEndTouch()
    func slideToPayEndSlider()
    func slideAddToCartButtonClick()
}

extension SlideToActionViewDelegate {
    func slideToPayBeginTouch() {
        
    }
    
    func slideToPayEndTouch() {
        
    }
    
    func slideAddToCartButtonClick() {
        
    }
}
