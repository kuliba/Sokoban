

import UIKit

class NewProductCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId: String = "NewProductCell"
    
    let transferImage = UIImageView()
    let transferLabel = UILabel(text: "", font: .systemFont(ofSize: 14), color: .white)
    let descriptionLabel = UILabel(text: "", font: .systemFont(ofSize: 12), color: .white)
    
    func configure<U>(with value: U) where U : Hashable {
        guard let payment: PaymentsModel = value as? PaymentsModel else { return }
        transferImage.image = UIImage(named: payment.iconName ?? "")
        transferLabel.text = payment.name
        descriptionLabel.text = payment.description
        if payment.id == 98 || payment.id == 97 || payment.id == 96 || payment.id == 95{
            self.backgroundView?.alpha = 0.4
            transferImage.alpha = 0.4
            transferLabel.alpha = 0.4
            descriptionLabel.alpha = 0.4
            self.isUserInteractionEnabled = false
        } else {
            self.backgroundView?.alpha = 1
            transferImage.alpha = 1
            transferLabel.alpha = 1
            descriptionLabel.alpha = 1
            self.isUserInteractionEnabled = true
        }
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        self.layer.cornerRadius = 10
//        0.785
        transferImage.setDimensions(height: 32, width: 32)
        backgroundColor = UIColor(hexString: "F6F6F7")
        transferLabel.textColor = .black
        descriptionLabel.textColor = .gray
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        transferLabel.numberOfLines = 1
        
        addSubview(transferImage)
        addSubview(transferLabel)
        addSubview(descriptionLabel)
        
        transferImage.contentMode = .scaleAspectFit
//        transferImage.setDimensions(height: 32, width: 32)
//        transferImage.centerX(inView: self, topAnchor: self.topAnchor, paddingTop: 16)
//        descriptionLabel.anchor(left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingLeft: 12, paddingBottom: 8, paddingRight: 12)
//        transferLabel.anchor(top: descriptionLabel.topAnchor ,left: self.leftAnchor, right: self.rightAnchor, paddingLeft: 12, paddingBottom: 0, paddingRight: 12)

        transferImage.setDimensions(height: 32, width: 32)
        backgroundColor = UIColor(hexString: "F6F6F7")
        transferImage.anchor(top: self.topAnchor, left: self.leftAnchor, paddingTop: 12, paddingLeft: 12)
        transferLabel.textColor = .black
        descriptionLabel.textColor = .gray
        descriptionLabel.anchor(left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingLeft: 12, paddingBottom: 8, paddingRight: 12)
        transferLabel.anchor(left: self.leftAnchor, bottom: descriptionLabel.topAnchor, right: self.rightAnchor, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)
    }
}
