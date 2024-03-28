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
    let transferLabel = UILabel(text: "", font: .systemFont(ofSize: 14), color: .white)
    
    func configure<U>(with value: U, getUImage: @escaping (Md5hash) -> UIImage?) where U : Hashable {
        guard let payment: PaymentsModel = value as? PaymentsModel else { return }
        transferImage.image = UIImage(named: payment.iconName ?? "")
        transferLabel.text = payment.name
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
        
        transferImage.contentMode = .scaleAspectFit
        transferImage.setDimensions(height: 48, width: 48)
        transferImage.centerX(inView: self, topAnchor: self.topAnchor, paddingTop: 16)
        transferLabel.anchor(left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingLeft: 12, paddingBottom: 10, paddingRight: 12)
        
    }
}
