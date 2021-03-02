import UIKit

protocol SspActTermsCellDelegate: AnyObject {
    func sspActTermsCell(_ sspActTermsCell: SspActTermsCell, didInteractWith URL: URL)
}

final class SspActTermsCell: UITableViewCell {
    
    // MARK: - Views / Delegates
    
    weak var delegate: SspActTermsCellDelegate?
    
    lazy var waveImageContainerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 0.45)
        
        addSubview(containerView)
        
        return containerView
    }()
    
    lazy var waveImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "PRODUCT_DETAIL_RECEIPT_STRIP")
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        waveImageContainerView.addSubview(imageView)

        return imageView
    }()
    
    lazy var summaryView: UIView = {
        let summaryView = UIImageView()
        summaryView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(summaryView)

        return summaryView
    }()
    
    lazy var termsTextView: UITextView = {
        let textView = UITextView()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        
        addSubview(textView)
        
        textView.attributedText = NSMutableAttributedString(string: "Terms & Conditions")
        textView.isSelectable = true
        textView.isEditable = false
        textView.isScrollEnabled = false
        
 
        
        return textView
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        activeViewsConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        activeViewsConstraints()
    }
    
    private func activeViewsConstraints() {
        activeWaveImageContainerConstraints()
        activeWaveImageViewConstraints()
        activeSummaryViewConstraints()
        activeTermsTextViewConstraints()
    }
    
    // MARK: - UI Configuration/Management
    
    private func activeWaveImageContainerConstraints() {
        NSLayoutConstraint.activate(
            [
                waveImageContainerView.topAnchor.constraint(equalTo: topAnchor),
                waveImageContainerView.heightAnchor.constraint(equalToConstant: 48),
                waveImageContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
                waveImageContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ]
        )
    }
    
    private func activeWaveImageViewConstraints() {
        NSLayoutConstraint.activate(
            [
                waveImageView.bottomAnchor.constraint(equalTo: waveImageContainerView.bottomAnchor),
                waveImageView.heightAnchor.constraint(equalToConstant: 17),
                waveImageView.leadingAnchor.constraint(equalTo: waveImageContainerView.leadingAnchor),
                waveImageView.trailingAnchor.constraint(equalTo: waveImageContainerView.trailingAnchor),
            ]
        )
    }
    
    
    private func activeSummaryViewConstraints() {
        NSLayoutConstraint.activate(
            [
                summaryView.topAnchor.constraint(equalTo: waveImageContainerView.bottomAnchor),
                summaryView.bottomAnchor.constraint(equalTo: bottomAnchor),
                summaryView.leadingAnchor.constraint(equalTo: leadingAnchor),
                summaryView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ]
        )
    }
    
    private func activeTermsTextViewConstraints() {
        NSLayoutConstraint.activate(
            [
                termsTextView.centerYAnchor.constraint(equalTo: summaryView.centerYAnchor),
                termsTextView.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor, constant: 12),
                termsTextView.trailingAnchor.constraint(equalTo: summaryView.trailingAnchor, constant: -12),
            ]
        )
    }
}

extension SspActTermsCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        delegate?.sspActTermsCell(self, didInteractWith: URL)
        
        return false
    }
}
