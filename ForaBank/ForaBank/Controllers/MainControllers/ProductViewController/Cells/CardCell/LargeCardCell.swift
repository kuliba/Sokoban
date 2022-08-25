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
        
        let viewModel = CardViewModelFromRealm(card: card)
        balanceLabel.text = viewModel.fullBalance
        maskCardLabel.text = viewModel.maskedcardNumber
        logoImageView.image = viewModel.logoImage
    }
    
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    
    static var reuseId: String = "LargeCardCell"
    //MARK: - Properties
    var card: UserAllCardsModel? {
        didSet {
            configure()
            
        }
    }
    
    public var backgroundUnlockColor = String()

    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    public let maskCardLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14 )
        label.text = ""
        return label
    }()
    
    public let dateEndLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14 )
        label.text = ""
        return label
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    public let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter-Regular", size: 14)
        label.textAlignment = .left
        label.text = ""
        return label
    }()
    
    public let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter-Regular", size: 12)
        label.textAlignment = .left
        label.text = ""
        return label
    }()
    
    public let interestRate: UILabel = {
        let label = PaddingLabel(withInsets: 1, 1, 5, 5)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        label.font = UIFont(name: "Inter-Regular", size: 12)
        label.textAlignment = .left
        label.text = ""
        return label
    }()

    public let cardNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter-Regular", size: 14)
        label.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        label.textAlignment = .left
        label.text = ""
        return label
    }()
    
    
    
    public let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
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
        
    }
    
    //MARK: - Helpers
    func configure() {
        guard let card = card else { return }
        
        let viewModel = CardViewModelFromRealm(card: card)
        backgroundImageView.image = card.XLDesign?.convertSVGStringToImage()
        balanceLabel.text = viewModel.fullBalance
        balanceLabel.textColor = viewModel.colorText
        dateEndLabel.text = viewModel.dateEnd
        dateEndLabel.textColor = viewModel.colorText
        amountLabel.textColor = viewModel.colorText
        cardNameLabel.text = viewModel.cardName
        cardNameLabel.textColor = viewModel.colorText
        cardNameLabel.alpha = 0.5
        
        if card.productType == "DEPOSIT"{
            guard let number = viewModel.card.accountNumber else {
                return
            }
            maskCardLabel.text = String(number.digits.suffix(4))
        } else {
            
            maskCardLabel.text = viewModel.maskedcardNumber
        }
        
        if card.productType == ProductType.loan.rawValue {
            
            balanceLabel.text = "\(viewModel.totalAmountDebt ?? "")"
            
            maskCardLabel.text = viewModel.settlementAccount?.suffix(4).description
            
            amountLabel.text =  "/ \(viewModel.amount)"
            
        } else {
            
            amountLabel.text =  ""
        }
        
        if card.productType != ProductType.loan.rawValue {
            
            dateEndLabel.isHidden = true
            dividerView.isHidden = true
        } else {
            
            dateEndLabel.isHidden = false
            dividerView.isHidden = false
        }
        
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
        addSubview(interestRate)
        addSubview(amountLabel)
        addSubview(dateEndLabel)
        addSubview(dividerView)
        
        backgroundImageView.fillSuperview()
        
        maskCardLabel.anchor(top: self.topAnchor, left: self.leftAnchor, paddingTop: 15, paddingLeft: 55, paddingRight: 12)
        dividerView.anchor(top: self.topAnchor, left: maskCardLabel.rightAnchor, paddingTop: 16, paddingLeft: 10, width: 1, height: 14)
        dateEndLabel.anchor(top: self.topAnchor, left: dividerView.rightAnchor, paddingTop: 15, paddingLeft: 10)
        
        logoImageView.centerY(inView: maskCardLabel)
        logoImageView.anchor(left: self.leftAnchor,
                             paddingLeft: 28, width: 18, height: 18)
        
        cardNameLabel.anchor(left: self.leftAnchor, bottom: balanceLabel.topAnchor, right: self.rightAnchor,
                             paddingTop: 12, paddingLeft: 12, paddingBottom: 5, paddingRight: 8)
        
        balanceLabel.font = UIFont.boldSystemFont(ofSize: 14)
        balanceLabel.anchor(left: self.leftAnchor, bottom: self.bottomAnchor,
                            paddingLeft: 12, paddingBottom: 16, paddingRight: 30)
        interestRate.anchor(bottom: self.bottomAnchor, right: self.rightAnchor,
                            paddingLeft: 12, paddingBottom: 16, paddingRight: 10)
        interestRate.backgroundColor = UIColor(hexString: "e1e1e2")
        
        amountLabel.anchor(left: balanceLabel.rightAnchor, bottom: balanceLabel.bottomAnchor, right: self.rightAnchor)
        amountLabel.textAlignment = .left

        
    }
}
