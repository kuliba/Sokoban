//
//  PaymentsViewControllerDelegate.swift
//  ForaBank
//
//  Created by Mikhail on 04.06.2021.
//

import UIKit
import RealmSwift
import SwiftUI

protocol PaymentsViewControllerDelegate: AnyObject {
    func toMobilePay(_ controller: UIViewController, _ phone: String)
    func goToCountryPayments()
    func goToPaymentByPhone()
}

extension PaymentsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unknown section kind")
        }
        switch section {
        case .payments:
            if let lastCountryPaymentModel = payments[indexPath.row].lastCountryPayment {
                openCountryPaymentVC(model: lastCountryPaymentModel)
            } else if let lastPhonePayment = payments[indexPath.row].lastPhonePayment {
                openPhonePaymentVC(model: lastPhonePayment)
            } else if let lastMobilePayment = payments[indexPath.row].lastMobilePayment {
                let viewController = (payments[indexPath.row].controllerName.getViewController() as? MobilePayViewController)!
                let phoneNumber = lastMobilePayment.additionalList?.filter {
                    $0.fieldName == "a3_NUMBER_1_2"
                }
    
                if let number = phoneNumber?.first?.fieldValue {

                    let formattedPhone = phoneFormatter.format(number)
                    viewController.phoneField.text = formattedPhone
                    viewController.selectNumber = formattedPhone
                }

                let vc = UINavigationController(rootViewController: viewController)
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            } else if let lastUtilitiesPayment = payments[indexPath.row].lastGKHPayment {
                openLatestUtilities(lastGKHPayment: lastUtilitiesPayment)
            } else if let lastUtilitiesPayment = payments[indexPath.row].lastInternetPayment {
                openLatestUtilities(lastGKHPayment: lastUtilitiesPayment)
                
            } else if payments[indexPath.row].type == "templates" {
                
                //FIXME: inject from parent view model after refactoring
                let model = Model.shared
                let templatesViewModel = TemplatesListViewModel(model, dismissAction: {}, updateFastAll: {})
                let templatesViewController = TemplatesListViewHostingViewController(with: templatesViewModel)
                templatesViewController.delegate = self
                let navigationViewController = UINavigationController(rootViewController: templatesViewController)
                present(navigationViewController, animated: true)
                
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
                let model = ConfirmViewControllerModel(type: .card2card, status: .succses)
                let popView = CustomPopUpWithRateView()
                popView.viewModel = model
                popView.modalPresentationStyle = .custom
                popView.transitioningDelegate = self
                self.present(popView, animated: true, completion: nil)
            } else if indexPath.row == 3 {
                let popView = MemeDetailVC()
                popView.titleLabel.text = "На другую карту"
                popView.modalPresentationStyle = .custom
                popView.transitioningDelegate = self
                self.present(popView, animated: true, completion: nil)
            } else {
                if let viewController = transfers[indexPath.row].controllerName.getViewController() {
                    let navController = UINavigationController(rootViewController: viewController)
                    if transfers[indexPath.row].name == "По номеру телефона" {
                        navController.modalPresentationStyle = .formSheet
//                        navController.transitioningDelegate = self
                    } else {
                        navController.modalPresentationStyle = .fullScreen
                    }
                    present(navController, animated: true, completion: nil)
                }
            }
        case .pay:
            switch (indexPath.row) {
            case 0:
                PermissionHelper.checkCameraAccess(isAllowed: { granted, alert in
                    if granted {
                        DispatchQueue.main.async {
                            let controller = QRViewController.storyboardInstance()!
                            let nc = UINavigationController(rootViewController: controller)
                            nc.modalPresentationStyle = .fullScreen
                            self.present(nc, animated: true)
                        }
                    } else {
                        DispatchQueue.main.async {
                            if let alertUnw = alert {
                                self.present(alertUnw, animated: true, completion: nil)
                            }
                        }
                    }
                })
                break
            case 1:
                // Мобильная связь
                let viewController = pay[indexPath.row].controllerName.getViewController()
                viewController?.addCloseButton()
                let navVC = UINavigationController(rootViewController: viewController ?? UIViewController())
                navVC.modalPresentationStyle = .fullScreen
                present(navVC, animated: true, completion: nil)
                break
            case 2:
                // ЖКХ
                InternetTVMainViewModel.filter = GlobalModule.UTILITIES_CODE
                let controller = InternetTVMainController.storyboardInstance()!
                let nc = UINavigationController(rootViewController: controller)
                nc.modalPresentationStyle = .fullScreen
                present(nc, animated: true)
                break
            case 3:
                // Интернет ТВ
                InternetTVMainViewModel.filter = GlobalModule.INTERNET_TV_CODE
                let controller = InternetTVMainController.storyboardInstance()!
                let nc = UINavigationController(rootViewController: controller)
                nc.modalPresentationStyle = .fullScreen
                present(nc, animated: true)
                break
            case 4:
                // Штрафы
                InternetTVMainViewModel.filter = GlobalModule.PAYMENT_TRANSPORT
                let controller = InternetTVMainController.storyboardInstance()!
                let nc = UINavigationController(rootViewController: controller)
                nc.modalPresentationStyle = .fullScreen
                present(nc, animated: true)
                break
            case 5:
                // Налоги
                /*
                let viewModel = PaymentsViewModel(category: Payments.Category.taxes, model: Model.shared, closeAction: {})
                let vc = PaymentsHoustingViewController(with: viewModel)
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
                 */
                break
                
            default:
                break
            }
        }
    }

    private func openLatestUtilities(lastGKHPayment: GetAllLatestPaymentsDatum) {
        let amount = lastGKHPayment.amount?.string() ?? ""
        var name = ""
        var image: UIImage!
        let realm = try? Realm()
        if let operatorsArray = realm?.objects(GKHOperatorsModel.self).filter { item in
            item.puref == lastGKHPayment.puref }
                , operatorsArray.count > 0, let foundedOperator = operatorsArray.first {
            name = foundedOperator.name?.capitalizingFirstLetter() ?? ""
            if let svgImage = foundedOperator.logotypeList.first?.svgImage, svgImage != "" {
                image = svgImage.convertSVGStringToImage()
            } else {
                image = UIImage(named: "GKH")
            }
            var additionalList = [AdditionalListModel]()
            lastGKHPayment.additionalList?.forEach { item in
                let additionalItem = AdditionalListModel()
                additionalItem.fieldValue = item.fieldValue
                additionalItem.fieldName = item.fieldName
                additionalItem.fieldTitle = item.fieldName
                additionalList.append(additionalItem)
            }
            let latestOpsDO = InternetLatestOpsDO(mainImage: image, name: name, amount: amount, op: foundedOperator, additionalList: additionalList)
            InternetTVMainViewModel.latestOp = latestOpsDO
            InternetTVMainViewModel.filter = foundedOperator.parentCode ?? GlobalModule.UTILITIES_CODE
            let controller = InternetTVMainController.storyboardInstance()!
            let nc = UINavigationController(rootViewController: controller)
            nc.modalPresentationStyle = .fullScreen
            present(nc, animated: false)
        }
    }

    private func openPhonePaymentVC(model: GetAllLatestPaymentsDatum) {
        let vc = PaymentByPhoneViewController(viewModel: PaymentByPhoneViewModel(phoneNumber: model.phoneNumber, bankId: model.bankID ?? ""))
        vc.phoneField.chooseButton.isHidden = true
        vc.phoneField.rightButton.isHidden = true
        vc.addCloseButton()
        vc.modalPresentationStyle = .fullScreen
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }

    private func openCountryPaymentVC(model: GetAllLatestPaymentsDatum) {
        let vc = ContactInputViewController()
        let country = getCountry(code: model.countryCode ?? "")
        vc.country = country
        if country.code == "TR" {
            
            if model.firstName != nil, model.middleName != nil, model.surName != nil, model.phoneNumber != nil {
                
                vc.typeOfPay = .contact
                //            vc.configure(with: model.country, byPhone: false)
                vc.foraSwitchView.bankByPhoneSwitch.isOn = false
                vc.foraSwitchView.bankByPhoneSwitch.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                vc.foraSwitchView.bankByPhoneSwitch.thumbTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                vc.nameField.text = model.firstName!
                vc.surnameField.text = model.surName!
                vc.secondNameField.text = model.middleName!
                vc.phoneField.text = model.phoneNumber!
            }
        } else {
            
            if model.phoneNumber != nil {
                
                vc.typeOfPay = .mig
                vc.configure(with: country, byPhone: true)
                vc.selectedBank = findBankByPuref(purefString: model.puref ?? "")
                let mask = StringMask(mask: "+000-0000-00-00")
                let maskPhone = mask.mask(string: model.phoneNumber)
                vc.phoneField.text = maskPhone ?? ""
                
            } else if model.firstName != nil, model.middleName != nil, model.surName != nil {
                
                vc.typeOfPay = .contact
                vc.configure(with: country, byPhone: false)
                vc.foraSwitchView.bankByPhoneSwitch.isOn = false
                vc.foraSwitchView.bankByPhoneSwitch.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                vc.foraSwitchView.bankByPhoneSwitch.thumbTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                vc.nameField.text = model.firstName!
                vc.surnameField.text = model.surName!
                vc.secondNameField.text = model.middleName!
            }
        }
        vc.addCloseButton()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true, completion: nil)
    }

    func getCountry(code: String) -> CountriesList {
        var countryValue: CountriesList?
        let list = Dict.shared.countries
        list?.forEach({ country in
            if country.code == code {
                countryValue = country
            }
        })
        return countryValue!
    }

    func findBankByPuref(purefString: String) -> BanksList? {
        var bankValue: BanksList?
        let paymentSystems = Dict.shared.paymentList
        paymentSystems?.forEach({ paymentSystem in
            if paymentSystem.code == "DIRECT" {
                let purefList = paymentSystem.purefList
                purefList?.forEach({ puref in
                    puref.forEach({ (key, value) in
                        value.forEach { purefList in
                            if purefList.puref == purefString {
                                let bankList = Model.shared.dictionaryBankListLegacy
                                bankList?.forEach({ bank in
                                    if bank.memberID == key {
                                        bankValue = bank
                                    }
                                })
                            }
                        }
                    })
                })
            }
        })
        return bankValue
    }
}

extension PaymentsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        presenter.height = 490
        return presenter
    }
}

//MARK: - TemplatesListViewHostingViewControllerDelegate

extension PaymentsViewController: TemplatesListViewHostingViewControllerDelegate {
    
    func presentProductViewController() {
        
        guard let tabBarController = tabBarController,
              let mainViewControllerNavigation = tabBarController.viewControllers?.first as? UINavigationController,
              let mainViewController = mainViewControllerNavigation.viewControllers.first as? MainViewController  else {
                  return
              }
        
        tabBarController.selectedIndex = 0
        mainViewController.presentProductViewController()
    }
}


