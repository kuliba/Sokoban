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
            } else {
                if let viewController = payments[indexPath.row].controllerName.getViewController() {
                    viewController.addCloseButton()
                    let navVC = UINavigationController(rootViewController: viewController)
                    navVC.modalPresentationStyle = .fullScreen
                    present(navVC, animated: true)
                }
            }
        case .transfers:
            if indexPath.row == 0 {
                let popView = MemeDetailVC()
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
                    } else {
                        navController.modalPresentationStyle = .fullScreen

                    }
                    present(navController, animated: true, completion: nil)
                }
            }
        case .pay:
            print("DEBUG: " + #function + pay[indexPath.row].name)
            
            if let viewController = pay[indexPath.row].controllerName.getViewController() {
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
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

extension PaymentsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

