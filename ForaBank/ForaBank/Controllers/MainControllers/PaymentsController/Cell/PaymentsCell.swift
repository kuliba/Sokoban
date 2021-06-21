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
//    let avatarImageView = UIImageView()
    let titleLabel = UILabel(text: "", font: .systemFont(ofSize: 11, weight: .regular), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
    
    
    func configure<U>(with value: U) where U : Hashable {
        guard let payment: PaymentsModel = value as? PaymentsModel else { return }
        
        titleLabel.text = payment.name
        
        if let iconName = payment.iconName {
            iconImageView.image = UIImage(named: iconName)
        }
        
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
//        addSubview(avatarImageView)
        
        let view = UIView()
        addSubview(view)
        view.setDimensions(height: 56, width: 56)
        view.centerX(inView: self, topAnchor: self.topAnchor)
        view.layer.cornerRadius = 56 / 2
        view.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.968627451, alpha: 1)
        
        
        addSubview(titleLabel)
        addSubview(iconImageView)
        
        
        //        avatarImageView.centerX(inView: self, topAnchor: self.topAnchor)
//        avatarImageView.setDimensions(height: 56, width: 56)
        
        iconImageView.center(inView: view)
        iconImageView.setDimensions(height: 32, width: 32)
        
        titleLabel.anchor(left: self.leftAnchor, right: self.rightAnchor)
        titleLabel.centerX(inView: view,
                           topAnchor: view.bottomAnchor, paddingTop: 8)
        
//        avatarImageView.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.968627451, alpha: 1)
//        avatarImageView.layer.cornerRadius = 28
        
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        
    }
}
