//
//  LargeCardCell.swift
//  ForaBank
//
//  Created by Дмитрий on 15.09.2021.
//

import Foundation
import UIKit
import SwiftUI


class LargeCardCell: UICollectionViewCell, SelfConfiguringCell {
  
   
    func configure<U>(with value: U) where U : Hashable {
        guard let card = card else { return }
        
        let viewModel = CardViewModel(card: card)
        balanceLabel.text = viewModel.balance
        maskCardLabel.text = viewModel.maskedcardNumber
        logoImageView.image = viewModel.logoImage
    }
    
    
    static var reuseId: String = "LargeCardCell"
    //MARK: - Properties
    var card: GetProductListDatum? {
        didSet {
//            backgroundUnlockColor = card?.background[0] ?? "ffffff"
            configure()
            
        }
    }
    
    public var backgroundUnlockColor = String()

    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
//        imageView.setDimensions(height: 20, width: 20)
        return imageView
    }()
    
    public let maskCardLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14 )
        label.text = ""
        return label
    }()

    public let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter-Regular", size: 14)
//        label.font = UIFont.boldSystemFont(ofSize: 11 )
        label.textAlignment = .left
        label.text = ""
        return label
    }()

    public let cardNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter-Regular", size: 14)
        label.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        label.textAlignment = .left
        label.text = "Зарплатная"
        return label
    }()
    
    public let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        backgroundImageView.image = card.XLDesign?.convertSVGStringToImage()
        balanceLabel.text = viewModel.balance
        balanceLabel.textColor = viewModel.colorText
        cardNameLabel.text = viewModel.cardName
        cardNameLabel.textColor = viewModel.colorText
        cardNameLabel.alpha = 0.5
        maskCardLabel.text = viewModel.maskedcardNumber
        maskCardLabel.textColor = viewModel.colorText
        logoImageView.image = viewModel.logoImage
    }
    
    func setupUI() {
        backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.968627451, alpha: 1)
        layer.cornerRadius = 12
        layer.shadowColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1).cgColor
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize()
//        0.785
        let shadowPath = UIBezierPath(
            rect: CGRect(x: 15, y: 20,
                         width: self.frame.width * 0.785,
                         height: self.frame.height * 0.785))
        layer.shadowPath = shadowPath.cgPath
        
        
        addSubview(backgroundImageView)
        addSubview(logoImageView)
        addSubview(maskCardLabel)
        addSubview(cardNameLabel)
        addSubview(balanceLabel)
//        addSubview(customizeSlideToOpen)
//
//        customizeSlideToOpen.delegate = self
//        customizeSlideToOpen.center(inView: self)
//        customizeSlideToOpen.anchor(width: 167, height: 48)
//        slideToUnlock.center(inView: self)
        
        backgroundImageView.fillSuperview()
        
        maskCardLabel.anchor(top: self.topAnchor, left: self.leftAnchor, right: self.rightAnchor, paddingTop: 15, paddingLeft: 55, paddingRight: 12)
//        maskCardLabel.centerY(inView: logoImageView)
        logoImageView.centerY(inView: maskCardLabel)
        logoImageView.anchor(left: self.leftAnchor,
                             paddingLeft: 28, width: 18, height: 18)
        
        
        cardNameLabel.anchor(left: self.leftAnchor, bottom: balanceLabel.topAnchor, right: self.rightAnchor,
                             paddingTop: 12, paddingLeft: 12, paddingBottom: 5, paddingRight: 8)
        
        balanceLabel.font = UIFont.boldSystemFont(ofSize: 14)
        balanceLabel.anchor(left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor,
                            paddingLeft: 12, paddingBottom: 16, paddingRight: 30)
    }
    
}
