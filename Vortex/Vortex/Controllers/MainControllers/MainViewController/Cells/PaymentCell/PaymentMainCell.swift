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
    
    let iconImageView: UIImageView =  {
        
        let iconImageView = UIImageView(frame: .zero)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return iconImageView
    }()
    
    let avatarImageView: UIImageView = {
        
        let avatarImageView = UIImageView(frame: .zero)
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 56 / 2
        avatarImageView.clipsToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return avatarImageView
    }()
    
    
    let initialsLabel: UILabel = {
        
        let label = UILabel(text: "", font: .boldSystemFont(ofSize: 12), color: #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1))
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let titleLabel: UILabel = {
        
        let label = UILabel(text: "", font: .systemFont(ofSize: 12, weight: .regular), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let iconCountryImageView: UIImageView = {
        
        let imageView = UIImageView(image: UIImage())
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(height: 24, width: 24)
        imageView.layer.cornerRadius = 24 / 2
        imageView.clipsToBounds = true
        imageView.isHidden = true
        
        return imageView
    }()
    
    let iconBackgroundView: UIView = {
        
        let iconBackgroundView = UIView()
        iconBackgroundView.layer.cornerRadius = 56 / 2
        iconBackgroundView.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.968627451, alpha: 1)
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        return iconBackgroundView
    }()
    
    func configure<U>(with value: U) where U : Hashable {
        guard let payment: PaymentsModel = value as? PaymentsModel else { return }
        titleLabel.text = payment.name
        if let iconName = payment.iconName {
            iconImageView.image = UIImage(named: iconName)
        }
//        if payment.id == 83 || payment.id == 84 {
//            
//            titleLabel.alpha = 0.3
//            avatarImageView.alpha = 0.3
//            iconImageView.alpha = 0.3
//            
//        } else {
//            titleLabel.alpha = 1
//            avatarImageView.alpha = 1
//            iconImageView.alpha = 1
//        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupUI() {
        
        let container = UIStackView(frame: .zero)
        container.axis = .vertical
        container.distribution = .fill
        container.alignment = .center
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        NSLayoutConstraint.activate([
            
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        let iconView = UIView(frame: .zero)
        iconView.backgroundColor = .clear
        container.addArrangedSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = true
        container.addArrangedSubview(iconView)
        iconView.widthAnchor.constraint(equalToConstant: 56).isActive = true
        let iconViewHeightAnchor = iconView.heightAnchor.constraint(equalToConstant: 56)
        iconViewHeightAnchor.priority = .defaultLow
        iconViewHeightAnchor.isActive = true

        iconView.addSubview(iconBackgroundView)
        NSLayoutConstraint.activate([
            
            iconBackgroundView.leadingAnchor.constraint(equalTo: iconView.leadingAnchor),
            iconBackgroundView.trailingAnchor.constraint(equalTo: iconView.trailingAnchor),
            iconBackgroundView.topAnchor.constraint(equalTo: iconView.topAnchor),
            iconBackgroundView.bottomAnchor.constraint(equalTo: iconView.bottomAnchor)
        ])
        
        iconView.addSubview(initialsLabel)
        NSLayoutConstraint.activate([
            
            initialsLabel.leadingAnchor.constraint(equalTo: iconView.leadingAnchor),
            initialsLabel.trailingAnchor.constraint(equalTo: iconView.trailingAnchor),
            initialsLabel.topAnchor.constraint(equalTo: iconView.topAnchor),
            initialsLabel.bottomAnchor.constraint(equalTo: iconView.bottomAnchor)
        ])
        
        iconView.addSubview(iconImageView)
        NSLayoutConstraint.activate([
            
            iconImageView.leadingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: 12),
            iconImageView.trailingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: -12),
            iconImageView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 12),
            iconImageView.bottomAnchor.constraint(equalTo: iconView.bottomAnchor, constant: -12)
        ])
        
        iconView.addSubview(iconCountryImageView)
        NSLayoutConstraint.activate([
            iconCountryImageView.topAnchor.constraint(equalTo: iconView.topAnchor),
            iconCountryImageView.rightAnchor.constraint(equalTo: iconView.rightAnchor, constant: 8)
        ])
        
        iconView.addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            
            avatarImageView.leadingAnchor.constraint(equalTo: iconView.leadingAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: iconView.trailingAnchor),
            avatarImageView.topAnchor.constraint(equalTo: iconView.topAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: iconView.bottomAnchor)
        ])

        container.addArrangedSubview(titleLabel)
    }
}
