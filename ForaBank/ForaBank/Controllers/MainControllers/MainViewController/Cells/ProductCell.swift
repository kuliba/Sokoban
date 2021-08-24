//
//  ProductCell.swift
//  ForaBank
//
//  Created by Дмитрий on 11.08.2021.
//

import Foundation
import UIKit


class ProductCell: UICollectionViewCell, SelfConfiguringCell {
   
    func configure<U>(with value: U) where U : Hashable {
        guard let card = card else { return }
        
        let viewModel = CardViewModel(card: card)
        balanceLabel.text = viewModel.balance
        maskCardLabel.text = viewModel.maskedcardNumber
        logoImageView.image = viewModel.logoImage
        
//        balanceLabel.text = contactInitials(model: payment.lastCountryPayment)
    }
    
    
    static var reuseId: String = "ProductCell"
    //MARK: - Properties
    var card: GetProductListDatum? {
        didSet { configure() }
    }
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(height: 24, width: 24)
        return imageView
    }()
    
    private let maskCardLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11 )
        label.text = ""
        return label
    }()

    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 11 )
        label.text = ""
        return label
    }()

    private let cardNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 11 )
        label.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        label.text = "Зарплатная"
        return label
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc func hendleShareTapped() {
        print(#function)
    }
    
    //MARK: - Helpers
    func configure() {
        guard let card = card else { return }
        
        let viewModel = CardViewModel(card: card)
        balanceLabel.text = viewModel.balance
        maskCardLabel.text = viewModel.maskedcardNumber
        logoImageView.image = viewModel.logoImage
    }
    
    func setupUI() {
        backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.968627451, alpha: 1)
        layer.cornerRadius = 8
//        clipsToBounds = true
        addSubview(logoImageView)
        addSubview(maskCardLabel)
        addSubview(cardNameLabel)
        addSubview(balanceLabel)
        
        self.layer.shadowColor = UIColor.black.cgColor
        layer.shadowColor = #colorLiteral(red: 0.2117647059, green: 0.01568627451, blue: 0.01568627451, alpha: 1).cgColor
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 0)
//        0.785
        let shadowPath = UIBezierPath(rect: CGRect(x: 26, y: 50, width: self.frame.width * 0.785, height: self.frame.height * 0.785))
        layer.shadowPath = shadowPath.cgPath
        
        logoImageView.anchor(top: self.topAnchor, left: self.leftAnchor,
                             paddingTop: 8, paddingLeft: 12)
        
        maskCardLabel.anchor(right: self.rightAnchor, paddingRight: 12)
        maskCardLabel.centerY(inView: logoImageView, leftAnchor: logoImageView.rightAnchor,
                              paddingLeft: 8)
        
        cardNameLabel.anchor(top: maskCardLabel.bottomAnchor, left: self.leftAnchor, right: self.rightAnchor,
                             paddingTop: 4, paddingLeft: 12, paddingRight: 12)
        
        balanceLabel.anchor(left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor,
                            paddingLeft: 12, paddingBottom: 8, paddingRight: 12)
    }
    
}
