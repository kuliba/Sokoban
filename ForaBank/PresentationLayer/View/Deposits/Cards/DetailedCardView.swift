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
    let cardHolderNameLabel = UILabel()

    let cardValidityPeriodLabel = UILabel()
    let cardCashLabel = UILabel()
    let cardBlockedImageView = UIImageView()
    var logoImageViewCosntraint: NSLayoutConstraint? = nil
    var expirationDate = UILabel()
    var newName: String = ""



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
            cardHolderNameLabel.textColor = foregroundColor
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
        addSubview(cardHolderNameLabel)
        self.addSubview(cardValidityPeriodLabel)
        self.addSubview(cardCashLabel)
        self.addSubview(paypassLogoImageView)
        self.addSubview(cardBlockedImageView)
        //constraints
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        cardHolderNameLabel.translatesAutoresizingMaskIntoConstraints = false
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
            if let availableBalance = card?.balance {
                cash = cashFormatter.string(from: NSNumber(value: availableBalance)) ?? ""
            }
            let foregroundColor = UIColor.white//UIColor.white
//            if card?.type?.rawValue.range(of: "mastercard", options: .caseInsensitive) != nil {
//                foregroundColor = UIColor.black
//            }
            guard let name = card?.name else {
                return
            }
            if card?.customName == "" {
                card?.customName = name
            }

            titleLabel.attributedText = NSAttributedString(string: card?.customName ?? "\(name)", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: foregroundColor])
            //cardView.titleLabel.sizeToFit()


            titleLabel.text = newName
            if newName == "" {
                titleLabel.attributedText = NSAttributedString(string: card?.customName ?? "\(name)", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: foregroundColor])
            }


            cardCashLabel.adjustsFontSizeToFitWidth = true
            cardCashLabel.attributedText = NSAttributedString(string: cash, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: foregroundColor])

            if card?.number.prefix(6) == "465626" {
                backgroundImageView.image = UIImage(named: "card_visa_gold")
            }
            else if card?.number.prefix(6) == "457825" {
                backgroundImageView.image = UIImage(named: "card_visa_platinum")
            }
            else if card?.number.prefix(6) == "425690" {
                backgroundImageView.image = UIImage(named: "card_visa_debet")
            }
            else if card?.number.prefix(6) == "557986" {
                backgroundImageView.image = UIImage(named: "card_visa_standart")

                titleLabel.textColor = .black
                cardCashLabel.textColor = .black
                cardNumberLabel.textColor = .black
                cardHolderNameLabel.textColor = .black
                cardValidityPeriodLabel.textColor = .black


            }
            else if card?.number.prefix(6) == "536466" {
                backgroundImageView.image = UIImage(named: "card_visa_virtual")
            }
            else if card?.number.prefix(6) == "470336" {
                backgroundImageView.image = UIImage(named: "card_visa_infinity")

            }
            else {
                backgroundImageView.image = UIImage(named: "card_visa_debet")
            }


            color2 = UIColor(red: 0.96, green: 0.45, blue: 0.13, alpha: 1)
            color1 = UIColor(red: 0.89, green: 0.77, blue: 0.35, alpha: 1)

            cardNumberLabel.attributedText = NSAttributedString(string: maskedCardNumber(number: card?.number ?? "", separator: " "), attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: foregroundColor])
            cardHolderNameLabel.attributedText = NSAttributedString(string: card?.holderName ?? "", attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: foregroundColor])

            if card?.number.prefix(6) == "557986" {
                backgroundImageView.image = UIImage(named: "card_visa_standart")

                titleLabel.textColor = .black
                cardCashLabel.textColor = .black
                cardNumberLabel.textColor = .black
                cardValidityPeriodLabel.textColor = .black

            }

            cardHolderNameLabel.text = card?.holderName

            expirationDate.text = card?.expirationDate
            cardValidityPeriodLabel.attributedText = NSAttributedString(string: monthYear(milisecond: card?.validThru ?? 0), attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: foregroundColor])

            if card?.type?.rawValue.range(of: "visa", options: .caseInsensitive) != nil {
                logoImageView.image = UIImage(named: "card_visa_logo")
            } else if card!.type?.rawValue.range(of: "mastercard", options: .caseInsensitive) != nil {
                logoImageView.image = UIImage(named: "card_mastercard_logo")
            }

            if card!.paypass == true {
                paypassLogoImageView.image = UIImage(named: "card_paypass_logo")
            }
            if card!.blocked == true {
                cardBlockedImageView.image = UIImage(named: "card_blocked")
                if card?.number.prefix(6) == "465626" {
                    backgroundImageView.image = UIImage(named: "card_visa_gold")
                }
                else if card?.number.prefix(6) == "457825" {
                    backgroundImageView.image = UIImage(named: "card_visa_platinum")
                }
                else if card?.number.prefix(6) == "425690" {
                    backgroundImageView.image = UIImage(named: "card_visa_debet")
                }
                else if card?.number.prefix(6) == "557986" {
                    backgroundImageView.image = UIImage(named: "card_visa_standart")
                    titleLabel.textColor = .black
                    cardCashLabel.textColor = .black
                    cardNumberLabel.textColor = .black
                    cardHolderNameLabel.textColor = .black
                    cardValidityPeriodLabel.textColor = .black
                }
                else if card?.number.prefix(6) == "536466" {
                    backgroundImageView.image = UIImage(named: "card_visa_virtual")
                }
                else if card?.number.prefix(6) == "470336" {
                    backgroundImageView.image = UIImage(named: "card_visa_infinity")
                } else {
                    backgroundImageView.image = UIImage(named: "card_visa_debet")

                }

            }
        }

        var horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[titleLabel(150)]-[cardCashLabel]-20-|", options: .alignAllCenterY, metrics: nil, views: ["titleLabel": titleLabel, "cardCashLabel": cardCashLabel])
        self.addConstraints(horizontalConstraints)
        var verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[titleLabel]", options: .alignAllCenterX, metrics: nil, views: ["titleLabel": titleLabel])
        self.addConstraints(verticalConstraints)
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[cardCashLabel(20)]", options: .alignAllCenterX, metrics: nil, views: ["cardCashLabel": cardCashLabel])
        self.addConstraints(verticalConstraints)

        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[backgroundImageView]-0-|", options: .alignAllCenterY, metrics: nil, views: ["backgroundImageView": backgroundImageView])
        self.addConstraints(horizontalConstraints)
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[backgroundImageView]-0-|", options: .alignAllCenterX, metrics: nil, views: ["backgroundImageView": backgroundImageView])
        self.addConstraints(verticalConstraints)

        // align cardHolderNameLabel from the left and right
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": cardHolderNameLabel]))

        // align cardHolderNameLabel from the top and bottom
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[cardNumberLabel]-0-[cardHolderNameLabel]-20-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["cardNumberLabel": cardNumberLabel, "cardHolderNameLabel": cardHolderNameLabel]))
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[cardNumberLabel(150)]", options: [], metrics: nil, views: ["cardNumberLabel": cardNumberLabel])
        self.addConstraints(horizontalConstraints)

        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[cardValidityPeriodLabel]-20-[paypassLogoImageView]", options: [], metrics: nil, views: ["cardHolderNameLabel": cardHolderNameLabel, "cardValidityPeriodLabel": cardValidityPeriodLabel, "paypassLogoImageView": paypassLogoImageView])
        self.addConstraints(horizontalConstraints)
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[cardNumberLabel(20)]-0-[cardValidityPeriodLabel(20)]-20-|", options: [], metrics: nil, views: ["cardNumberLabel": cardNumberLabel, "cardValidityPeriodLabel": cardValidityPeriodLabel])
        self.addConstraints(verticalConstraints)

        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[paypassLogoImageView(13)]-7-[logoImageView]-20-|", options: [], metrics: nil, views: ["logoImageView": logoImageView, "paypassLogoImageView": paypassLogoImageView])
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
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[logoImageView(18)]-20-|", options: [], metrics: nil, views: ["logoImageView": logoImageView])
        self.addConstraints(verticalConstraints)
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[paypassLogoImageView(16)]-21-|", options: [], metrics: nil, views: ["paypassLogoImageView": paypassLogoImageView])
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
        if card!.blocked == true {
            cardBlockedImageView.image = UIImage(named: "card_blocked")
        }
    }
}
