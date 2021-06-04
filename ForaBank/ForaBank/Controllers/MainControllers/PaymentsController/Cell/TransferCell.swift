//
//  TransferCell.swift
//  ForaBank
//
//  Created by Mikhail on 03.06.2021.
//

import UIKit

class TransferCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId: String = "TransferCell"
    
    let transferImage = UIImageView()
    let transferLabel = UILabel(text: "", font: .systemFont(ofSize: 11), color: .white)
    
    func configure<U>(with value: U) where U : Hashable {
        guard let payment: PaymentsModel = value as? PaymentsModel else { return }
        transferImage.image = UIImage(named: payment.iconName ?? "")
        transferLabel.text = payment.name
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        self.layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.backgroundColor = #colorLiteral(red: 0.262745098, green: 0.2392156863, blue: 0.2392156863, alpha: 1)
        transferLabel.numberOfLines = 2
        
        addSubview(transferImage)
        addSubview(transferLabel)
        
        transferImage.contentMode = .scaleAspectFit
        transferImage.setDimensions(height: 46, width: 46)
        transferImage.centerX(inView: self, topAnchor: self.topAnchor, paddingTop: 12)
        transferLabel.anchor(left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingLeft: 12, paddingBottom: 8, paddingRight: 20)
        
    }
}
