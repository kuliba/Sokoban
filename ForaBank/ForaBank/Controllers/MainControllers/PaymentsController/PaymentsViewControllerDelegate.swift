//
//  PaymentsViewControllerDelegate.swift
//  ForaBank
//
//  Created by Mikhail on 04.06.2021.
//

import UIKit

extension PaymentsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unknown section kind")
        }
        switch section {
        case .payments:
            print("DEBUG: " + #function + payments[indexPath.row].name)
            if let lastCountryPaymentModel = payments[indexPath.row].lastCountryPayment {
                openCountryPaymentVC(model: lastCountryPaymentModel)
            } else if let lastPhonePayment = payments[indexPath.row].lastPhonePayment {
                openPhonePaymentVC(model: lastPhonePayment)
            } else {
                if let viewController = payments[indexPath.row].controllerName.getViewController() {
                    viewController.addCloseButton()
                    let navVC = UINavigationController(rootViewController: viewController)
                    navVC.modalPresentationStyle = .fullScreen
                    present(navVC, animated: true)
                }
            }
        case .transfers:
            if indexPath.row == 1 {
                let popView = CustomPopUpWithRateView()
//                popView.onlyMy = false
                popView.modalPresentationStyle = .custom
                popView.transitioningDelegate = self
                self.present(popView, animated: true, completion: nil)
                
            } else if indexPath.row == 3 {
                let popView = MemeDetailVC()
                popView.onlyMy = false
                popView.onlyCard = true
                popView.titleLabel.text = "На другую карту"
                popView.modalPresentationStyle = .custom
                popView.transitioningDelegate = self
                self.present(popView, animated: true, completion: nil)
            } else {
                print("DEBUG: " + #function + transfers[indexPath.row].name)
                if let viewController = transfers[indexPath.row].controllerName.getViewController() {
                    let navController = UINavigationController(rootViewController: viewController)
                    if transfers[indexPath.row].name == "По номеру телефона"{
                        navController.modalPresentationStyle = .formSheet
//                        navController.transitioningDelegate = self
                    } else {
                        navController.modalPresentationStyle = .fullScreen
                        
                    }
                    present(navController, animated: true, completion: nil)
                }
            }
        case .pay:
            print("DEBUG: " + #function + pay[indexPath.row].name)
       
            if let viewController = pay[indexPath.row].controllerName.getViewController() {
                viewController.addCloseButton()
                let navVC = UINavigationController(rootViewController: viewController)
                navVC.modalPresentationStyle = .fullScreen
//                    present(navVC, animated: true)
                
//                    // ЖКХ
                if indexPath.row == 2 {
                    let gkh = GKHMainViewController.storyboardInstance()!
                    let nc = UINavigationController(rootViewController: gkh)
                    nc.modalPresentationStyle = .fullScreen
                    present(nc, animated: true)
                } 
//                    // Мобильная связь
//                    if indexPath.row == 1 {
//                        let gkh = MobilePayViewController()
//                        let nc = UINavigationController(rootViewController: gkh)
//                        nc.modalPresentationStyle = .fullScreen
//                        present(nc, animated: true)
//                    } else {
//                        present(navVC, animated: true)
//                    }
//                present(navVC, animated: true)
                present(navVC, animated: true, completion: nil)
            }
        }
    }
    
    
    
    private func openPhonePaymentVC(model: GetLatestPaymentsDatum) {
        let vc = PaymentByPhoneViewController()
        
        let banksList = Dict.shared.banks
        banksList?.forEach { bank in
            if bank.memberID == model.bankID {
                vc.selectedBank = bank
                vc.bankId = bank.memberID ?? ""
            }
        }
        
//        vc.selectBank = model.bankName
//        vc.memberId = model.bankID
//        vc.bankImage = UIImage(named: "\(model.bankID ?? "")")
        let mask = StringMask(mask: "+7 (000) 000-00-00")
        let maskPhone = mask.mask(string: model.phoneNumber)
        vc.phoneField.text = maskPhone ?? ""
        vc.selectNumber = maskPhone
        if model.bankName == "ФОРА-БАНК"{
            vc.sbp = false
        } else {
            vc.sbp = true
        }
        vc.phoneField.chooseButton.isHidden = true
        vc.phoneField.rightButton.isHidden = true
        
        
        vc.addCloseButton()
        vc.modalPresentationStyle = .fullScreen
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
//        navController.transitioningDelegate = self
        self.present(navController, animated: true, completion: nil)
        
    }
    
    private func openCountryPaymentVC(model: ChooseCountryHeaderViewModel) {
        let vc = ContactInputViewController()
        vc.country = model.country
        if model.phoneNumber != nil {
            vc.typeOfPay = .mig
            vc.configure(with: model.country, byPhone: true)
            vc.selectedBank = model.bank
            let mask = StringMask(mask: "+000-0000-00-00")
            let maskPhone = mask.mask(string: model.phoneNumber)
            vc.phoneField.text = maskPhone ?? ""
        } else if model.firstName != nil, model.middleName != nil, model.surName != nil {
            vc.typeOfPay = .contact
            vc.configure(with: model.country, byPhone: false)
            vc.foraSwitchView.bankByPhoneSwitch.isOn = false
            vc.foraSwitchView.bankByPhoneSwitch.layer.borderColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            vc.foraSwitchView.bankByPhoneSwitch.thumbTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            vc.nameField.text = model.firstName!
            vc.surnameField.text = model.surName!
            vc.secondNameField.text = model.middleName!
        }
        vc.addCloseButton()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        self.present(navVC, animated: true, completion: nil)
    }
    
}

extension PaymentsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}


