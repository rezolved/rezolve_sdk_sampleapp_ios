import Foundation
import RezolveSDK

final class SspActDescriptionCell: UITableViewCell {
    
    // MARK: - Views
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont(name: "OpenSans-Bold", size: 20.0)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont(name: "OpenSans-SemiBold", size: 12.0)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont(name: "OpenSans", size: 13.0)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    lazy var textsContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubviews([titleLabel, subtitleLabel, descriptionLabel])
        
        addSubview(stackView)
        
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 20.0
        
        return stackView
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSeparatorView()
        activeTextsContainerStackViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        activeTextsContainerStackViewConstraints()
    }
    
    private func activeTextsContainerStackViewConstraints() {
        NSLayoutConstraint.activate(
             [
                 textsContainerStackView.topAnchor.constraint(equalTo: topAnchor, constant: 12.0),
                 textsContainerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12.0),
                 textsContainerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.0),
                 textsContainerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.0),
             ]
         )
    }
    
    // MARK: - UI Configuration/Management
    
    private func addSeparatorView() {
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        
        addSubview(separatorView)

        NSLayoutConstraint.activate(
            [
                separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
                separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
                separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
                separatorView.heightAnchor.constraint(equalToConstant: 1.0)
            ]
        )
    }
    
    func setupLabels(sspAct: SspAct) {
        titleLabel.text = sspAct.name
        subtitleLabel.text = sspAct.shortDescription
        subtitleLabel.isHidden = sspAct.shortDescription?.isEmpty ?? true
        descriptionLabel.text = sspAct.longDescription
    }
}
