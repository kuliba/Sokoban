//
//  DetailedCardView.swift
//  ForaBank
//
//  Created by Sergey on 14/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class DetailedCardView: UIView {

    let backgroundImageView = UIImageView()
    let logoImageView = UIImageView()
    let paypassLogoImageView = UIImageView()
    let titleLabel = UILabel()
    let cardNumberLabel = UILabel()
    let cardValidityPeriodLabel = UILabel()
    let cardCashLabel = UILabel()
    let cardBlockedImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
        
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[paypassLogoImageView(13)]-7-[logoImageView(41)]-20-|", options: [], metrics: nil, views: ["logoImageView":logoImageView, "paypassLogoImageView":paypassLogoImageView])
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
