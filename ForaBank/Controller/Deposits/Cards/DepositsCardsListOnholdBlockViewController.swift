/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit

class DepositsCardsListOnholdBlockViewController: UIViewController {
    
    var card: Card? = nil
    let ppvc: OptionPickerViewController = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "ppvc") as! OptionPickerViewController
    
    let optionPickerButton = OptionPickerButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DepositsCardsListOnholdBlockViewController viewDidLoad")

        //кнопка назад
        let backButton = UIButton(type: .system)
        backButton.tintColor = .black
        backButton.setImage(UIImage(named: "back_button"), for: .normal)
        self.view.addSubview(backButton)
        backButton.addTarget(self, action: #selector(backButtonClicked(_:)), for: .touchUpInside)
        //заголовок экрана
        let titleLabel = UILabel()
        titleLabel.text = "Блокировка карты"
        self.view.addSubview(titleLabel)
        //view карты
        let selectedCardView = DetailedCardView(withCard: card!)
        //тестовые данные
        //        selectedCardView.titleLabel.attributedText = NSAttributedString(string: "Visa Gold Cashback", attributes: [.font:UIFont.systemFont(ofSize: 16), .foregroundColor : UIColor.white])
        //        selectedCardView.cardCashLabel.attributedText = NSAttributedString(string: "21 350 ₽", attributes: [.font:UIFont.systemFont(ofSize: 16), .foregroundColor : UIColor.white])
        //        selectedCardView.backgroundImageView.image = UIImage(named: "card_visa_gold")
        //        selectedCardView.cardNumberLabel.attributedText = NSAttributedString(string: "2345 4567 8907 9706", attributes: [.font:UIFont.systemFont(ofSize: 12), .foregroundColor : UIColor.white])
        //        selectedCardView.cardValidityPeriodLabel.attributedText = NSAttributedString(string: "08/18", attributes: [.font:UIFont.systemFont(ofSize: 12), .foregroundColor : UIColor.white])
        //        selectedCardView.logoImageView.image = UIImage(named: "deposit_cards_list_onhold_visa_logo")
        //        selectedCardView.paypassLogoImageView.image = UIImage(named: "deposit_cards_list_onhold_paypass_logo")
        self.view.addSubview(selectedCardView)
        //label причина блокировки
        let reasonLabel = UILabel()
        reasonLabel.attributedText = NSAttributedString(string: "Причина блокировки", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        self.view.addSubview(reasonLabel)
        //pickerButton
        
        optionPickerButton.tintColor = .black
        optionPickerButton.setTitle("Карта утеряна", for: .normal)
        optionPickerButton.setTitleColor(UIColor.black, for: .normal)
        optionPickerButton.contentHorizontalAlignment = .left
        self.view.addSubview(optionPickerButton)
        optionPickerButton.addTarget(self, action: #selector(optionPickerButtonClicked(_:)), for: .touchUpInside)
        //popupPickerVC
        //popupVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        //popupVC.modalTransitionStyle = .crossDissolve
        ppvc.modalPresentationStyle = .overCurrentContext
        ppvc.modalTransitionStyle = .crossDissolve
        
        //blockButton
        let blockButton = CardActionRoundedButton(type: .system)
        blockButton.tintColor = .black
        blockButton.setAttributedTitle(NSAttributedString(string: "Заблокировать карту", attributes: [.font:UIFont.systemFont(ofSize: 15)]), for: .normal)
        blockButton.addTarget(self, action: #selector(blockButtonClicked(_:)), for: .touchUpInside)
        self.view.addSubview(blockButton)
        
        //constraints
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        selectedCardView.translatesAutoresizingMaskIntoConstraints = false
        reasonLabel.translatesAutoresizingMaskIntoConstraints = false
        optionPickerButton.translatesAutoresizingMaskIntoConstraints = false
        blockButton.translatesAutoresizingMaskIntoConstraints = false
        //title
        view.addConstraint(NSLayoutConstraint(item: titleLabel,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: titleLabel,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 150))
        let metrics = ["yPos":UIApplication.shared.statusBarFrame.height+5]
        var verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(yPos)-[titleLabel(20)]", options: [], metrics: metrics, views: ["titleLabel":titleLabel])
        view.addConstraints(verticalConstraints)
        //back button
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[backButton(8)]", options: [], metrics: nil, views: ["backButton":backButton])
        view.addConstraints(horizontalConstraints)
        view.addConstraint(NSLayoutConstraint(item: backButton,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: titleLabel,
                                              attribute: .centerY,
                                              multiplier: 1,
                                              constant: 2))
        //card view
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
        //reasonLabel
        view.addConstraint(NSLayoutConstraint(item: reasonLabel,
                                              attribute: .left,
                                              relatedBy: .equal,
                                              toItem: selectedCardView,
                                              attribute: .left,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: reasonLabel,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 130))
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[selectedCardView]-15-[reasonLabel(15)]", options: [], metrics: nil, views: ["reasonLabel":reasonLabel,"selectedCardView":selectedCardView])
        view.addConstraints(verticalConstraints)
        //reasonPickerButton
        view.addConstraint(NSLayoutConstraint(item: optionPickerButton,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: selectedCardView,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: optionPickerButton,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: selectedCardView,
                                              attribute: .width,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: optionPickerButton,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: reasonLabel,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 5))
        view.addConstraint(NSLayoutConstraint(item: optionPickerButton,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 35))
        //blockButton
        view.addConstraint(NSLayoutConstraint(item: blockButton,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: selectedCardView,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: blockButton,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: selectedCardView,
                                              attribute: .width,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: blockButton,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: optionPickerButton,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 20))
        view.addConstraint(NSLayoutConstraint(item: blockButton,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 45))
    }
    
    @objc func backButtonClicked(_ sender: UIButton!) {
        dismiss(animated: true, completion: nil)
        //navigationController?.popViewController(animated: true)
    }
    
    @objc func blockButtonClicked(_ sender: UIButton!) {
        //navigationController?.popToRootViewController(animated: true)
//        CardManager.shared().blockCard(withNumber: card!.number)
        //navigationController?.dismiss(animated: true, completion: nil)
        NetworkManager.shared().blockCard(withNumber: card?.number ?? "") { [unowned self] (success) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func optionPickerButtonClicked(_ sender: UIButton!) {
        if let vc = UIStoryboard(name: "Payment", bundle: nil)
            .instantiateViewController(withIdentifier: "ppvc") as? OptionPickerViewController {
            
            // Pass picker frame to determine picker popup coordinates
            vc.pickerFrame = optionPickerButton.frame
            vc.pickerFrame.origin.x = vc.pickerFrame.origin.x + 25
            vc.pickerFrame.size.width = vc.pickerFrame.size.width - 25
            vc.pickerOptions = ["Карта утеряна", "Карта украдена", "Компроментация карты", "Карта изъята банком"]
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
}

extension DepositsCardsListOnholdBlockViewController: OptionPickerDelegate {
    func setSelectedOption(option: String?) {
        if let option = option {
            optionPickerButton.setTitle(option, for: [])
        }
    }
}
