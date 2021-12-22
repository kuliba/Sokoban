//
//  PaymentsViewControllerDelegate.swift
//  ForaBank
//
//  Created by Mikhail on 04.06.2021.
//

import UIKit


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
                let number = phoneNumber?.first?.fieldValue ?? ""
                // delegate?.toMobilePay(viewController, number )
                let mask = StringMask(mask: "+7 (000) 000-00-00")
                let maskPhone = mask.mask(string: number)
                viewController.phoneField.text = maskPhone ?? ""
                viewController.selectNumber = maskPhone
                let vc = UINavigationController(rootViewController: viewController)
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            } else if let lastGKHPayment = payments[indexPath.row].lastGKHPayment{
                    
                    let viewController = GKHInputViewController()
                    viewController.addCloseButton()
                    
//                let op = GKHOperatorsModel??.self
//                    viewController.operatorData = op
                    viewController.operatorType = true
                    let navVC = UINavigationController(rootViewController: viewController)
                    navVC.modalPresentationStyle = .fullScreen
                    present(navVC, animated: true)
            } else {
                if let viewController = payments[indexPath.row].controllerName.getViewController() {
                    viewController.addCloseButton()
                    let navVC = UINavigationController(rootViewController: viewController)
                    navVC.modalPresentationStyle = .fullScreen
                    present(navVC, animated: true)
                }
            }
        case .transfers:
//            if indexPath.row == 0 {
//                delegate?.goToPaymentByPhone()
//             } else
            if indexPath.row == 1 {
                let model = ConfirmViewControllerModel(type: .card2card)
                let popView = CustomPopUpWithRateView()
                popView.viewModel = model
//                popView.onlyMy = false
                popView.modalPresentationStyle = .custom
                popView.transitioningDelegate = self
                self.present(popView, animated: true, completion: nil)
//            } else if indexPath.row == 2 {
//                delegate?.goToCountryPayments()
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
                checkCameraAccess(isAllowed: {
                    if $0 {
                        DispatchQueue.main.async {
                            let controller = QRViewController.storyboardInstance()!
                            let nc = UINavigationController(rootViewController: controller)
                            nc.modalPresentationStyle = .fullScreen
                            self.present(nc, animated: true)
                        }
                    } else {
                        guard self.alertController == nil else {
                            print("There is already an alert presented")
                            return
                        }
                        self.alertController = UIAlertController(title: "Внимание", message: "Для сканирования QR кода, необходим доступ к камере", preferredStyle: .alert)
                        guard let alert = self.alertController else {
                            return
                        }
                        alert.addAction(UIAlertAction(title: "Понятно", style: .default, handler: { (action) in
                            self.alertController = nil
                        }))
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
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
            default:
                break
            }
        }
    }

    private func openPhonePaymentVC(model: GetAllLatestPaymentsDatum) {
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
        if model.bankName == "ФОРА-БАНК" {
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
        present(navController, animated: true, completion: nil)
    }

    private func openCountryPaymentVC(model: GetAllLatestPaymentsDatum) {
        let vc = ContactInputViewController()
        let country = getCountry(code: model.countryCode ?? "")
        vc.country = country
        if model.phoneNumber != nil {
            vc.typeOfPay = .mig
            vc.configure(with: country, byPhone: true)
            vc.selectedBank = findBankByPuref(purefString: model.puref ?? "")
            let mask = StringMask(mask: "+000-0000-00-00")
            let maskPhone = mask.mask(string: model.phoneNumber)
            vc.phoneField.text = maskPhone ?? ""
        } else if model.firstName != nil, model.middleName != nil, model.surName != nil {
            vc.typeOfPay = .contact
//            vc.configure(with: model.country, byPhone: false)
            vc.foraSwitchView.bankByPhoneSwitch.isOn = false
            vc.foraSwitchView.bankByPhoneSwitch.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            vc.foraSwitchView.bankByPhoneSwitch.thumbTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            vc.nameField.text = model.firstName!
            vc.surnameField.text = model.surName!
            vc.secondNameField.text = model.middleName!
        }
        vc.addCloseButton()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true, completion: nil)
    }
    
        func getCountry(code: String) -> CountriesList{
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
                               let bankList = Dict.shared.banks
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
        return bankValue!
   }
}
           
    

extension PaymentsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        presenter.height = 490
        return presenter
    }
}


