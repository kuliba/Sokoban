//
//  DepositsCardsListOnholdViewController.swift
//  ForaBank
//
//  Created by Sergey on 13/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import DeviceKit

class DepositsCardsListOnholdViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //UIImageView вместо UINavigationBar
        let backToCardsView = UIImageView()
        if Device().isOneOf(Constants.xDevices) {
            backToCardsView.image = UIImage(named: "deposit_cards_list_onhold_navigation_bar88")// models: x
        } else {
            backToCardsView.image = UIImage(named: "deposit_cards_list_onhold_navigation_bar64")// models 7 7+ se
        }
        backToCardsView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector (backToCardsViewClicked (_:)))
        backToCardsView.addGestureRecognizer(gesture)
        self.view.addSubview(backToCardsView)

        //view карты
        let selectedCardView = DetailedCardView()
        //тестовые данные
        selectedCardView.titleLabel.attributedText = NSAttributedString(string: "Visa Gold Cashback", attributes: [.font:UIFont.systemFont(ofSize: 16), .foregroundColor : UIColor.white])
        selectedCardView.cardCashLabel.attributedText = NSAttributedString(string: "21 350 ₽", attributes: [.font:UIFont.systemFont(ofSize: 16), .foregroundColor : UIColor.white])
        selectedCardView.backgroundImageView.image = UIImage(named: "card_visa_gold")
        selectedCardView.cardNumberLabel.attributedText = NSAttributedString(string: "2345 4567 8907 9706", attributes: [.font:UIFont.systemFont(ofSize: 12), .foregroundColor : UIColor.white])
        selectedCardView.cardValidityPeriodLabel.attributedText = NSAttributedString(string: "08/18", attributes: [.font:UIFont.systemFont(ofSize: 12), .foregroundColor : UIColor.white])
        selectedCardView.logoImageView.image = UIImage(named: "card_visa_logo")
        selectedCardView.paypassLogoImageView.image = UIImage(named: "card_paypass_logo")
        self.view.addSubview(selectedCardView)
        
        //кнопка перевода денег
        let sendMoneyButton = CardActionRoundedButton(type: .system)
        sendMoneyButton.tintColor = .black
        sendMoneyButton.setImage(UIImage(named: "deposit_cards_list_onhold_sendmoney_button"), for: .normal)
        self.view.addSubview(sendMoneyButton)
        
        //кнопка пополнения денег
        let addMoneyButton = CardActionRoundedButton(type: .system)
        addMoneyButton.tintColor = .black
        addMoneyButton.setImage(UIImage(named: "deposit_cards_list_onhold_addmoney_button"), for: .normal)
        self.view.addSubview(addMoneyButton)
        
        //кнопка блокировки карты
        let blockCardButton = CardActionRoundedButton()
        blockCardButton.layer.borderColor = UIColor(hexFromString: "EC433D").cgColor
        blockCardButton.setImage(UIImage(named: "deposit_cards_list_onhold_block_button"), for: .normal)
        blockCardButton.setImage(UIImage(named: "deposit_cards_list_onhold_block_button_highlighted"), for: .highlighted)
        self.view.addSubview(blockCardButton)
        blockCardButton.addTarget(self, action: #selector(blockCardButtonClicked), for: .touchUpInside)
        
        //кнопка "Все действия"
        let allActionButton = CardActionRoundedButton(type: .system)
        allActionButton.setAttributedTitle(NSAttributedString(string: "Все действия", attributes: [.font:UIFont.systemFont(ofSize: 15)]), for: .normal)
        //allActionButton.setTitleColor(.black, for: .normal)
        //allActionButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        allActionButton.tintColor = .black
        
        allActionButton.addTarget(self, action: #selector(allActionButtonClicked), for: .touchUpInside)
        self.view.addSubview(allActionButton)
        
        //constraints
        selectedCardView.translatesAutoresizingMaskIntoConstraints = false
        backToCardsView.translatesAutoresizingMaskIntoConstraints = false
        allActionButton.translatesAutoresizingMaskIntoConstraints = false
        sendMoneyButton.translatesAutoresizingMaskIntoConstraints = false
        addMoneyButton.translatesAutoresizingMaskIntoConstraints = false
        blockCardButton.translatesAutoresizingMaskIntoConstraints = false
        
        //for header
        var horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[backToCardsView]-|", options: .alignAllCenterY, metrics: nil, views: ["backToCardsView":backToCardsView])
        let metrics = ["viewHeight":(Device().isOneOf(Constants.xDevices) ? 88 : 64)]
        var verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[backToCardsView(viewHeight)]", options: .alignAllCenterX, metrics: metrics, views: ["backToCardsView":backToCardsView])
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
        //for card view
        //соотношения сторон карты (280к160) 1.75 или 0.57143
        //ширина карты к экрану 0.875
        let screenSize: CGRect = UIScreen.main.bounds
        let cardWidth = screenSize.width*0.875
        let cardHeight = CGFloat(cardWidth)*160/280
        view.addConstraint(NSLayoutConstraint(item: selectedCardView,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: selectedCardView,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: cardWidth))
        view.addConstraint(NSLayoutConstraint(item: selectedCardView,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .centerY,
                                              multiplier: 1,
                                              constant: -60))
        view.addConstraint(NSLayoutConstraint(item: selectedCardView,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: cardHeight))
        //кнопка перевода денег
        view.addConstraint(NSLayoutConstraint(item: sendMoneyButton,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: sendMoneyButton,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 45))
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[selectedCardView]-20-[sendMoneyButton(45)]", options: .alignAllCenterX, metrics: nil, views: ["sendMoneyButton":sendMoneyButton, "selectedCardView":selectedCardView])
        view.addConstraints(verticalConstraints)
        //кнопка пополнения денег
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[addMoneyButton(45)]-20-[sendMoneyButton]", options: [], metrics: nil, views: ["addMoneyButton":addMoneyButton,"sendMoneyButton":sendMoneyButton])
        view.addConstraints(horizontalConstraints)
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[selectedCardView]-20-[addMoneyButton(45)]", options: [], metrics: nil, views: ["addMoneyButton":addMoneyButton, "selectedCardView":selectedCardView])
        view.addConstraints(verticalConstraints)
        //кнопка блокировки карты
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[sendMoneyButton]-20-[blockCardButton(45)]", options: [], metrics: nil, views: ["blockCardButton":blockCardButton,"sendMoneyButton":sendMoneyButton])
        view.addConstraints(horizontalConstraints)
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[selectedCardView]-20-[blockCardButton(45)]", options: [], metrics: nil, views: ["blockCardButton":blockCardButton, "selectedCardView":selectedCardView])
        view.addConstraints(verticalConstraints)
        //кнопка "Все действия"
        view.addConstraint(NSLayoutConstraint(item: allActionButton,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: allActionButton,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 175))
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[blockCardButton]-20-[button(45)]", options: [], metrics: nil, views: ["button":allActionButton, "blockCardButton":blockCardButton])
        view.addConstraints(verticalConstraints)
    }
    
    @objc func allActionButtonClicked(sender: UIButton!) {
        performSegue(withIdentifier: "DepositsCardsDetailsViewController", sender: nil)
    }

    @objc func backToCardsViewClicked(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func blockCardButtonClicked(_ sender: UIButton!) {
        performSegue(withIdentifier: "CardListOnholdBlock", sender: nil)
    }

}

