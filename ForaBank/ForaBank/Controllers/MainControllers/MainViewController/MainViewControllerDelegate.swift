//
//  MainViewControllerDelegate.swift
//  ForaBank
//
//  Created by Дмитрий on 11.08.2021.
//

import UIKit

extension MainViewController: UICollectionViewDelegate {
    
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
            print("It's transfer")
        case .offer:
            print("It's transfer")
        case .pay:
            print("DEBUG: " + #function + pay[indexPath.row].name)
            if pay[indexPath.row].id == 19 {
                getFastPaymentContractList { [weak self] contractList, error in
                    if error != nil {
                        self?.showAlert(with: "Ошибка", and: error!)
                    } else {
                        DispatchQueue.main.async {
                            if let viewController = self?.pay[indexPath.row].controllerName.getViewController() {
                                viewController.addCloseButton()
                                let navVC = UINavigationController(rootViewController: viewController)
                                navVC.modalPresentationStyle = .fullScreen
                                self?.present(navVC, animated: true)
                            }
                        }
                    }
                }
            } else {
                if let viewController = pay[indexPath.row].controllerName.getViewController() {
                    viewController.addCloseButton()
                    let navVC = UINavigationController(rootViewController: viewController)
                    navVC.modalPresentationStyle = .fullScreen
                    present(navVC, animated: true)
                }
            }
        }
    }
    
    private func openPhonePaymentVC(model: GetLatestPaymentsDatum) {
        let vc = PaymentByPhoneViewController()
        
        let banksList = Dict.shared.banks
        banksList?.forEach { bank in
            if bank.memberID == model.bankID {
                vc.selectedBank = bank
            }
        }
        
//        vc.selectBank = model.bankName
//        vc.memberId = model.bankID
//        vc.bankImage = UIImage(named: "\(model.bankID ?? "")")
        let mask = StringMask(mask: "+7 (000) 000-00-00")
        let maskPhone = mask.mask(string: model.phoneNumber)
        vc.phoneField.text = maskPhone ?? ""
        if model.bankName == "ФОРА-БАНК"{
            vc.sbp = false
        } else {
            vc.sbp = true
        }
        
        vc.addCloseButton()
        vc.modalPresentationStyle = .fullScreen
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
        
    }
    
    private func openCountryPaymentVC(model: ChooseCountryHeaderViewModel) {
        let vc = ContactInputViewController()
        vc.country = model.country
        if model.phoneNumber != nil {
            vc.configure(with: model.country, byPhone: true)
            vc.selectedBank = model.bank
            let mask = StringMask(mask: "+000-0000-00-00")
            let maskPhone = mask.mask(string: model.phoneNumber)
            vc.phoneField.text = maskPhone ?? ""
        } else if model.firstName != nil, model.middleName != nil, model.surName != nil {
            vc.configure(with: model.country, byPhone: false)
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

extension MainViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}



