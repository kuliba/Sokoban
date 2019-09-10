//
//  DetailedCardView.swift
//  ForaBank
//
//  Created by Sergey on 14/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class DetailedCardView: CardView {
    var card: Card? = nil

    let backgroundImageView = UIImageView()
    let logoImageView = UIImageView()
    let paypassLogoImageView = UIImageView()
    let titleLabel = UILabel()
    let cardNumberLabel = UILabel()
    let cardValidityPeriodLabel = UILabel()
    let cardCashLabel = UILabel()
    let cardBlockedImageView = UIImageView()
    var logoImageViewCosntraint: NSLayoutConstraint? = nil
    var expirationDate = UILabel()
    
    
    
    enum CardBackGround: String {
        case mastercard = "mastercard_gold"
        case visaGold = "visa_gold"
        case visaPlatinum = "visa_platinum"
        case visaDebet = "visa_classic"
        case visaStandart = "visa_standart"
    }
    
    var foregroundColor: UIColor! {
        didSet {
            titleLabel.textColor = foregroundColor
            cardCashLabel.textColor = foregroundColor
            cardNumberLabel.textColor = foregroundColor
            cardValidityPeriodLabel.textColor = foregroundColor
        }
    }
    
    init(withCard card: Card) {
        self.card = card
        super.init(frame: CGRect.zero)
        addSubviews()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addSubviews() {
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 2
        cardCashLabel.textAlignment = .right
        //print("DetailedCardView init(frame: CGRect)")
        self.addSubview(backgroundImageView)
        self.addSubview(logoImageView)
        self.addSubview(titleLabel)
        self.addSubview(cardNumberLabel)
        self.addSubview(cardValidityPeriodLabel)
        self.addSubview(cardCashLabel)
        self.addSubview(paypassLogoImageView)
        self.addSubview(cardBlockedImageView)
        //constraints
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        cardValidityPeriodLabel.translatesAutoresizingMaskIntoConstraints = false
        cardCashLabel.translatesAutoresizingMaskIntoConstraints = false
        paypassLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        cardBlockedImageView.translatesAutoresizingMaskIntoConstraints = false
    
 
        
        if card != nil {
            let cashFormatter = NumberFormatter()
            cashFormatter.numberStyle = .currency
            cashFormatter.usesGroupingSeparator = true
            cashFormatter.groupingSeparator = ","
            cashFormatter.locale = Locale(identifier: "ru_RU")
            var cash = ""
            if let availableBalance = card!.availableBalance {
                cash = cashFormatter.string(from: NSNumber(value: availableBalance)) ?? ""
            }
            let foregroundColor = UIColor.white//UIColor.white
//            if card?.type?.rawValue.range(of: "mastercard", options: .caseInsensitive) != nil {
//                foregroundColor = UIColor.black
//            }
            titleLabel.attributedText = NSAttributedString(string: card?.title ?? "", attributes: [.font:UIFont.systemFont(ofSize: 16), .foregroundColor : foregroundColor])
            //cardView.titleLabel.sizeToFit()
            
            cardCashLabel.adjustsFontSizeToFitWidth = true
            cardCashLabel.attributedText = NSAttributedString(string: cash, attributes: [.font:UIFont.systemFont(ofSize: 16), .foregroundColor : foregroundColor])
            
            if card?.number?.prefix(6) == "465626" {
                backgroundImageView.image = UIImage(named: "card_visa_gold")
            }
            if card?.number?.prefix(6) == "457825" {
                backgroundImageView.image = UIImage(named: "card_visa_platinum")
            }
            if card?.number?.prefix(6) == "425690" {
                backgroundImageView.image = UIImage(named: "card_visa_debet")
            }
            if card?.number?.prefix(6) == "557986" {
                backgroundImageView.image = UIImage(named: "card_visa_standart")
            }
            if card?.number?.prefix(6) == "536466" {
                backgroundImageView.image = UIImage(named: "card_visa_virtual")
            }
            if card?.number?.prefix(6) == "470336" {
                backgroundImageView.image = UIImage(named: "card_visa_infinity")
            }
            
            
            color2 = UIColor(red: 0.96, green: 0.45, blue: 0.13, alpha: 1)
            color1 = UIColor(red: 0.89, green: 0.77, blue: 0.35, alpha: 1)
            
            cardNumberLabel.attributedText = NSAttributedString(string: card!.maskedNumber ?? "", attributes: [.font:UIFont.systemFont(ofSize: 12), .foregroundColor : foregroundColor])
            expirationDate.text = card?.expirationDate
            cardValidityPeriodLabel.attributedText = NSAttributedString(string: card!.validityPeriod ?? "", attributes: [.font:UIFont.systemFont(ofSize: 12), .foregroundColor : foregroundColor])
            if card?.type?.rawValue.range(of: "visa", options: .caseInsensitive) != nil {
                logoImageView.image = UIImage(named: "card_visa_logo")
            }
            else if card!.type?.rawValue.range(of: "mastercard", options: .caseInsensitive) != nil {
                logoImageView.image = UIImage(named: "card_mastercard_logo")
            }
            
            if card!.paypass == true {
                paypassLogoImageView.image = UIImage(named: "card_paypass_logo")
            }
            if card!.blocked == true {
                cardBlockedImageView.image = UIImage(named: "card_blocked")
            }
        }
        
        var horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[titleLabel(150)]-[cardCashLabel]-20-|", options: .alignAllCenterY, metrics: nil, views: ["titleLabel":titleLabel, "cardCashLabel":cardCashLabel])
        self.addConstraints(horizontalConstraints)
        var verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[titleLabel]", options: .alignAllCenterX, metrics: nil, views: ["titleLabel":titleLabel])
        self.addConstraints(verticalConstraints)
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[cardCashLabel(20)]", options: .alignAllCenterX, metrics: nil, views: ["cardCashLabel":cardCashLabel])
        self.addConstraints(verticalConstraints)
        
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[backgroundImageView]-0-|", options: .alignAllCenterY, metrics: nil, views: ["backgroundImageView":backgroundImageView])
        self.addConstraints(horizontalConstraints)
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[backgroundImageView]-0-|", options: .alignAllCenterX, metrics: nil, views: ["backgroundImageView":backgroundImageView])
        self.addConstraints(verticalConstraints)
        
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[cardNumberLabel(150)]", options: [], metrics: nil, views: ["cardNumberLabel":cardNumberLabel])
        self.addConstraints(horizontalConstraints)
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[cardValidityPeriodLabel(150)]", options: [], metrics: nil, views: ["cardValidityPeriodLabel":cardValidityPeriodLabel])
        self.addConstraints(horizontalConstraints)
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[cardNumberLabel(20)]-0-[cardValidityPeriodLabel(20)]-20-|", options: [], metrics: nil, views: ["cardNumberLabel":cardNumberLabel, "cardValidityPeriodLabel":cardValidityPeriodLabel])
        self.addConstraints(verticalConstraints)
        
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[paypassLogoImageView(13)]-7-[logoImageView]-20-|", options: [], metrics: nil, views: ["logoImageView":logoImageView, "paypassLogoImageView":paypassLogoImageView])
        var logoWidth = 0.0
        if card?.type?.rawValue.range(of: "visa", options: .caseInsensitive) != nil {
            logoWidth = 41
        }
        else if card?.type?.rawValue.range(of: "mastercard", options: .caseInsensitive) != nil {
            logoWidth = 29
        }
        
        logoImageViewCosntraint = NSLayoutConstraint(item: logoImageView,
                                                     attribute: .width,
                                                     relatedBy: .equal,
                                                     toItem: nil,
                                                     attribute: .notAnAttribute,
                                                     multiplier: 1,
                                                     constant: CGFloat(logoWidth))
        horizontalConstraints.append(logoImageViewCosntraint!)
        self.addConstraints(horizontalConstraints)
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[logoImageView(18)]-20-|", options: [], metrics: nil, views: ["logoImageView":logoImageView])
        self.addConstraints(verticalConstraints)
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[paypassLogoImageView(16)]-21-|", options: [], metrics: nil, views: ["paypassLogoImageView":paypassLogoImageView])
        self.addConstraints(verticalConstraints)
        
        self.addConstraint(NSLayoutConstraint(item: cardBlockedImageView,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        self.addConstraint(NSLayoutConstraint(item: cardBlockedImageView,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 1,
                                              constant: 0))
        self.addConstraint(NSLayoutConstraint(item: cardBlockedImageView,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 99))
        self.addConstraint(NSLayoutConstraint(item: cardBlockedImageView,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 99))
    }
    
    func update(withCard card: Card) {
        self.card = card
        self.subviews.forEach({ $0.removeFromSuperview() })
        addSubviews()
        blockCard()
    }
    
    func blockCard() {
//        print(card?.blocked as Any)
        if card!.blocked == true {
            cardBlockedImageView.image = UIImage(named: "card_blocked")
        }
    }
}
