//
//  PayCell.swift
//  ForaBank
//
//  Created by Mikhail on 03.06.2021.
//

import UIKit

class PayCell: UICollectionViewCell, SelfConfiguringCell {
    static var reuseId: String = "PayCell"
    
    let iconImageView = UIImageView()
    let paymentsName = UILabel(text: "Оплата",
                               font: .systemFont(ofSize: 16), color: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func configure<U>(with value: U) where U : Hashable {
        guard let payments: PaymentsModel = value as? PaymentsModel else { return }
        paymentsName.text = payments.name
        iconImageView.image = UIImage(named: payments.iconName ?? "")
        if paymentsName.text == "Соцсети, игры, карты" || paymentsName.text == "Охранные системы" ||  paymentsName.text == "Прочее" {
            iconImageView.alpha = 0.3
            paymentsName.alpha = 0.3
            self.isUserInteractionEnabled = false
        } else {
            iconImageView.alpha = 1
            paymentsName.alpha = 1
            self.isUserInteractionEnabled = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let backView = UIView()
        backView.layer.cornerRadius = 8
        backView.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.968627451, alpha: 1)
        paymentsName.numberOfLines = 2
        addSubview(backView)
        backView.addSubview(iconImageView)
        addSubview(paymentsName)
        self.alpha = 0.8
        backView.setDimensions(height: 48, width: 48)
        backView.centerY(inView: self, leftAnchor: self.leftAnchor)
        iconImageView.center(inView: backView)
        iconImageView.setDimensions(height: 32, width: 32)
        paymentsName.centerY(inView: backView, leftAnchor: backView.rightAnchor, paddingLeft: 16)
        paymentsName.anchor(right: self.rightAnchor, paddingRight: 8)
    }
}
