//
//  TransferCell.swift
//  ForaBank
//
//  Created by Mikhail on 03.06.2021.
//

import UIKit

class TransferCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId: String = "TransferCell"
    
    var mainCell = false
    
    let transferImage = UIImageView()
    let transferLabel = UILabel(text: "", font: .systemFont(ofSize: 14), color: .white)
    let descriptionLabel = UILabel(text: "", font: .systemFont(ofSize: 14), color: .white)

    
    func configure<U>(with value: U) where U : Hashable {
        guard let payment: PaymentsModel = value as? PaymentsModel else { return }
        transferImage.image = UIImage(named: payment.iconName ?? "")
        transferLabel.text = payment.name
        descriptionLabel.text = payment.description
//        if payment.id == 99 || payment.id == 98 || payment.id == 97 || payment.id == 96 || payment.id == 95 {
//                transferImage.setDimensions(height: 32, width: 32)
//                backgroundColor = UIColor(hexString: "F6F6F7")
//                transferImage.anchor(top: self.topAnchor, left: self.leftAnchor, paddingTop: 12, paddingLeft: 12)
//                transferLabel.textColor = .black
//                descriptionLabel.textColor = .black
//            
//
//        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        self.layer.cornerRadius = 10
        layer.shadowColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1).cgColor
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 0)
        
//        0.785
        let shadowPath = UIBezierPath(rect: CGRect(x: 15, y: 50, width: self.frame.width * 0.7, height: self.frame.height * 0.7))
        layer.shadowPath = shadowPath.cgPath
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.backgroundColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
        transferLabel.numberOfLines = 2
        
        addSubview(transferImage)
        addSubview(transferLabel)
        addSubview(descriptionLabel)
        
        transferImage.contentMode = .scaleAspectFit
        transferLabel.anchor(left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingLeft: 12, paddingBottom: 8, paddingRight: 12)
        descriptionLabel.anchor(top: transferLabel.topAnchor, left: self.leftAnchor, right: self.rightAnchor, paddingLeft: 12, paddingBottom: 8, paddingRight: 12)
        descriptionLabel.font = UIFont(name: "", size: 14)
//        if descriptionLabel.text == "" {
//                transferImage.setDimensions(height: 32, width: 32)
//                backgroundColor = UIColor(hexString: "F6F6F7")
//                transferImage.anchor(top: self.topAnchor, left: self.leftAnchor, paddingTop: 12, paddingLeft: 12)
//                transferLabel.textColor = .black
//                descriptionLabel.textColor = .black
//                transferLabel.anchor(left: self.leftAnchor, bottom: descriptionLabel.bottomAnchor, right: self.rightAnchor, paddingLeft: 12, paddingBottom: 8, paddingRight: 12)
//                descriptionLabel.anchor(left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingLeft: 12, paddingBottom: 8, paddingRight: 12)
//
//
//        } else {
//            transferImage.setDimensions(height: 48, width: 48)
//            transferImage.centerX(inView: self, topAnchor: self.topAnchor, paddingTop: 16)
//        }
        
    }
}
