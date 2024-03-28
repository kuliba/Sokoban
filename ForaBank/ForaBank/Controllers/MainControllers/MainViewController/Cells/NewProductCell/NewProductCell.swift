

import UIKit

class NewProductCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId: String = "NewProductCell"
    
    let transferImage = UIImageView()
    let transferLabel = UILabel(text: "", font: .systemFont(ofSize: 14), color: .white)
    let descriptionLabel = UILabel(text: "", font: .systemFont(ofSize: 12), color: .white)
    
    func configure<U>(with value: U, getUImage: @escaping (Md5hash) -> UIImage?) where U : Hashable {
        guard let payment: PaymentsModel = value as? PaymentsModel else { return }
        transferImage.image = UIImage(named: payment.iconName ?? "")
        transferLabel.text = payment.name
        descriptionLabel.text = payment.description
//        if
//            
//            payment.id == 97 || payment.id == 96 || payment.id == 95{
//            self.backgroundView?.alpha = 0.4
//            transferImage.alpha = 0.4
//            transferLabel.alpha = 0.4
//            descriptionLabel.alpha = 0.4
//            self.isUserInteractionEnabled = false
//        } else {
//            
//            self.backgroundView?.alpha = 1
//            transferImage.alpha = 1
//            transferLabel.alpha = 1
//            descriptionLabel.alpha = 1
//            self.isUserInteractionEnabled = true
//        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let container = UIStackView(frame: .zero)
        container.axis = .vertical
        container.distribution = .fill
        container.alignment = .leading
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        NSLayoutConstraint.activate([
            
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            container.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
        
        transferImage.contentMode = .scaleAspectFit
        transferImage.translatesAutoresizingMaskIntoConstraints = false
        container.addArrangedSubview(transferImage)
        NSLayoutConstraint.activate([
            
            transferImage.heightAnchor.constraint(lessThanOrEqualToConstant: 32),
            transferImage.widthAnchor.constraint(equalToConstant: 32)
        ])
        
        let spacerView = UIView(frame: .zero)
        spacerView.backgroundColor = .clear
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        container.addArrangedSubview(spacerView)
        
        transferLabel.numberOfLines = 1
        transferLabel.textColor = .black
        transferLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addArrangedSubview(transferLabel)
        
        descriptionLabel.numberOfLines = 1
        descriptionLabel.textColor = .gray
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addArrangedSubview(descriptionLabel)
        
        layer.cornerRadius = 10
        backgroundColor = UIColor(hexString: "F6F6F7")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
