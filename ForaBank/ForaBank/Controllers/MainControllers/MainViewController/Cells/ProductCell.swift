//
//  ProductCell.swift
//  ForaBank
//
//  Created by Дмитрий on 11.08.2021.
//

import Foundation
import UIKit


class ProductCell: UICollectionViewCell, SelfConfiguringCell {
   
//    var status: String?
//    var statusPC: String?
//
    func configure<U>(with value: U) where U : Hashable {
        guard let card = card else { return }
        
        let viewModel = CardViewModel(card: card)
        backgroundImageView.image =  card.largeDesign?.convertSVGStringToImage()
        balanceLabel.text = viewModel.balance
        balanceLabel.textColor = viewModel.colorText
        cardNameLabel.text = viewModel.cardName
        cardNameLabel.textColor = viewModel.colorText
        cardNameLabel.alpha = 0.5
        maskCardLabel.text = viewModel.maskedcardNumber
        maskCardLabel.textColor = viewModel.colorText
        logoImageView.image = viewModel.logoImage
        
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
        label.font = UIFont.systemFont(ofSize: 12 )
        label.text = ""
        return label
    }()

    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14 )
        label.text = ""
        return label
    }()

    private let cardNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14 )
        label.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        label.text = "Зарплатная"
        return label
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let statusImage: UIImageView = {
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
        
        backgroundImageView.image =  card.largeDesign?.convertSVGStringToImage()

        balanceLabel.text = viewModel.balance
        balanceLabel.textColor = viewModel.colorText
        cardNameLabel.text = viewModel.cardName
        cardNameLabel.textColor = viewModel.colorText
        cardNameLabel.alpha = 0.5
        maskCardLabel.text = viewModel.maskedcardNumber
        maskCardLabel.textColor = viewModel.colorText
        logoImageView.image = viewModel.logoImage
        if card.status == "Действует" || card.status == "Выдано клиенту", card.statusPC == "17"{
            statusImage.image = UIImage(named: "unactivated")
            maskCardLabel.alpha = 0.5
            cardNameLabel.alpha = 0.5
            balanceLabel.alpha = 0.5
            logoImageView.alpha = 0.5
            backgroundImageView.alpha = 0.8
        } else if card.status == "Заблокирована банком" || card.status == "Блокирована по решению Клиента" || card.status == "Блокирована по решению Клиента" || card.status == "BLOCKED_DEBET" || card.status == "BLOCKED_CREDIT" || card.status == "BLOCKED" , card.statusPC == "3" || card.statusPC == "5" || card.statusPC == "6" || card.statusPC == "7" || card.statusPC == "20" || card.statusPC == "21" || card.statusPC == nil{
            statusImage.image = UIImage(named: "blockProduct")
            maskCardLabel.alpha = 0.5
            cardNameLabel.alpha = 0.5
            balanceLabel.alpha = 0.5
            logoImageView.alpha = 0.5
            backgroundImageView.alpha = 0.8
        } else {
            statusImage.image = UIImage(named: "")
            maskCardLabel.alpha = 1
            cardNameLabel.alpha = 1
            balanceLabel.alpha = 1
            logoImageView.alpha = 1
            backgroundImageView.alpha = 1
        }
    }
    
    func setupUI() {
        
        backgroundColor = .clear
        layer.cornerRadius = 8
        layer.shadowColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1).cgColor
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.4
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
        addSubview(statusImage)
//        addSubview(slider ?? UISlider())

        
        backgroundImageView.fillSuperview()
        balanceLabel.font = UIFont.boldSystemFont(ofSize: 14)
        maskCardLabel.anchor(top: self.topAnchor, left: self.leftAnchor, right: self.rightAnchor, paddingTop: 17, paddingLeft: 55, paddingRight: 12)
        
        logoImageView.centerY(inView: maskCardLabel)
        logoImageView.anchor(left: self.leftAnchor,
                             paddingLeft: 16, width: 18, height: 18)
        
        
        
        statusImage.center(inView: self)
       
        cardNameLabel.anchor(top: maskCardLabel.bottomAnchor, left: self.leftAnchor, right: self.rightAnchor,
                             paddingTop: 25, paddingLeft: 12, paddingRight: 8)
        cardNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)

        balanceLabel.anchor(left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor,
                            paddingLeft: 12, paddingBottom: 11, paddingRight: 30)

    }
    
}
