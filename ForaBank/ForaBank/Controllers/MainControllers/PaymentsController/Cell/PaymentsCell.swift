//
//  PaymentsCell.swift
//  ForaBank
//
//  Created by Mikhail on 03.06.2021.
//

import UIKit

class PaymentsCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId: String = "PaymentsCell"
    
    let iconImageView = UIImageView()
    
    let initialsLabel: UILabel = {
        let label = UILabel(text: "", font: .boldSystemFont(ofSize: 16), color: #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1))
        label.textAlignment = .center
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel(text: "", font: .systemFont(ofSize: 11, weight: .regular), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    let iconCountryImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage())
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(height: 24, width: 24)
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
    }()
    
    func configure<U>(with value: U) where U : Hashable {
        guard let payment: PaymentsModel = value as? PaymentsModel else { return }
        
        titleLabel.text = payment.name
        
        if let iconName = payment.iconName {
            iconImageView.image = UIImage(named: iconName)
        }
        if payment.lastCountryPayment != nil {
            iconCountryImageView.isHidden = false
            iconImageView.isHidden = true
            if payment.lastCountryPayment?.phoneNumber != nil {
                initialsLabel.isHidden = true
                iconImageView.isHidden = false
            } else {
                initialsLabel.isHidden = false
            }
        } else {
            iconCountryImageView.isHidden = true
            initialsLabel.isHidden = true
            iconImageView.isHidden = false
            
        }
        iconCountryImageView.image = payment.lastCountryPayment != nil
            ? payment.lastCountryPayment?.countryImage
            : UIImage()
        
        initialsLabel.text = contactInitials(model: payment.lastCountryPayment)
        
        guard let avatarImageName = payment.avatarImageName else { return }
        guard let avatarImage = UIImage(named: avatarImageName) else { return }
        iconImageView.image = avatarImage
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupUI() {
        let view = UIView()
        addSubview(view)
        view.setDimensions(height: 56, width: 56)
        view.centerX(inView: self, topAnchor: self.topAnchor)
        view.layer.cornerRadius = 56 / 2
        view.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.968627451, alpha: 1)
        view.addSubview(initialsLabel)
        
        addSubview(titleLabel)
        addSubview(iconImageView)
        addSubview(iconCountryImageView)
             
        initialsLabel.fillSuperview()
        
        iconImageView.center(inView: view)
        iconImageView.setDimensions(height: 32, width: 32)
        
        titleLabel.anchor(left: self.leftAnchor, right: self.rightAnchor)
        titleLabel.centerX(
            inView: view, topAnchor: view.bottomAnchor, paddingTop: 8)
        
        iconCountryImageView.anchor(
            top: view.topAnchor, right: view.rightAnchor, paddingRight: -8)
    }
    
    func contactInitials(model: ChooseCountryHeaderViewModel?) -> String {
        var initials = String()
        
        if let firstNameFirstChar = model?.firstName?.first {
            initials.append(firstNameFirstChar)
        }
        
        if let lastNameFirstChar = model?.surName?.first {
            initials.append(lastNameFirstChar)
        }
        
        return initials
    }
    
}
