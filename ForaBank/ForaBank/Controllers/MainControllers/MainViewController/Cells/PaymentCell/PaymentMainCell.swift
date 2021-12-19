//
//  PaymentMainCell.swift
//  ForaBank
//
//  Created by Дмитрий on 09.09.2021.
//

import Foundation
import UIKit
import Contacts

class PaymentsMainCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId: String = "PaymentsMainCell"
    
    let iconImageView = UIImageView()
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 56/2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    
    let initialsLabel: UILabel = {
        let label = UILabel(text: "", font: .boldSystemFont(ofSize: 12), color: #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1))
        label.textAlignment = .center
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel(text: "", font: .systemFont(ofSize: 12, weight: .regular), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
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
        if payment.id == 82 || payment.id == 83 || payment.id == 84 {
            
            titleLabel.alpha = 0.3
            avatarImageView.alpha = 0.3
            iconImageView.alpha = 0.3
            
        } else {
            titleLabel.alpha = 1
            avatarImageView.alpha = 1
            iconImageView.alpha = 1
        }
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
//        self.backgroundColor = .systemGray6
        addSubview(titleLabel)
        addSubview(iconImageView)
        addSubview(iconCountryImageView)
        addSubview(avatarImageView)
             
        initialsLabel.fillSuperview()
        
        iconImageView.center(inView: view)
        iconImageView.setDimensions(height: 32, width: 32)
        
        titleLabel.anchor(left: self.leftAnchor, right: self.rightAnchor)
        titleLabel.centerX(
            inView: view, topAnchor: view.bottomAnchor, paddingTop: 8)
        
        iconCountryImageView.anchor(
            top: view.topAnchor, right: view.rightAnchor, paddingRight: -8)
        avatarImageView.center(inView: view)
        avatarImageView.setDimensions(height: 56, width: 56)
    }
    
    
    
    
}
