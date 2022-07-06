//
//  CountryPaymentView+Legacy.swift
//  ForaBank
//
//  Created by Дмитрий on 17.06.2022.
//

import Foundation
import SwiftUI

extension CountryPaymentView {
    
    struct ViewModel {
        
        let puref: String?
        let country: CountriesList?
        let paymentType: PaymentType
        let bank: BanksList?
        var paymentTemplate: PaymentTemplateData? = nil

        struct AddressViewModel {
            
            let firstName: String
            let middleName: String
            let surName: String
        }
        
        struct WithOutAddress {
            
            let phoneNumber: String?
        }
        
        enum PaymentType {
            
            case address(adressViewModel: AddressViewModel)
            case withOutAddress(withOutViewModel: WithOutAddress)
            case template(templateViewModel: PaymentTemplateData)
        }
        
        init(countryData: PaymentCountryData) {
            
            if let phoneNumber = countryData.phoneNumber {
                
                paymentType = .withOutAddress(withOutViewModel: .init(phoneNumber: phoneNumber))
            
            } else {
                
                paymentType = .address(adressViewModel: .init(firstName: countryData.firstName ?? "", middleName: countryData.middleName ?? "", surName: countryData.surName ?? ""))
            }

            self.puref = countryData.puref
            self.country = Model.shared.dictionaryCountry(for: countryData.countryCode)?.getCountriesList()
            self.bank = Model.shared.dictionaryBankList.first(where: {$0.memberNameRus == countryData.puref})?.getBanksList()
        }
        
        init(paymentTemplate: PaymentTemplateData) {
            
            self.paymentTemplate = paymentTemplate
            self.paymentType = .template(templateViewModel: paymentTemplate)
            self.puref = nil
            self.country = nil
            self.bank = nil
        }
    }
}

struct CountryPaymentView: UIViewControllerRepresentable {
    
    let viewModel: CountryPaymentView.ViewModel
    
    func makeUIViewController(context: Context) -> ContactInputViewController {
        
        var vc = ContactInputViewController()
        vc.country = viewModel.country
        
        //MARK: PaymentsViewController openCountryPaymentVC(206)
        switch viewModel.paymentType {
        case let .address(adressViewModel):
            
            vc.typeOfPay = .contact
            vc.foraSwitchView.bankByPhoneSwitch.isOn = false
            vc.foraSwitchView.bankByPhoneSwitch.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            vc.foraSwitchView.bankByPhoneSwitch.thumbTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            vc.configure(with: viewModel.country, byPhone: false)
            vc.nameField.text = adressViewModel.firstName
            vc.surnameField.text = adressViewModel.surName
            vc.secondNameField.text = adressViewModel.middleName
            vc.addCloseButton()
            
        case let .withOutAddress(withOutViewModel):
            
            vc.typeOfPay = .mig
            vc.configure(with: viewModel.country, byPhone: true)
            vc.selectedBank = viewModel.bank
            let mask = StringMask(mask: "+000-0000-00-00")
            let maskPhone = mask.mask(string: withOutViewModel.phoneNumber)
            vc.phoneField.text = maskPhone ?? ""
            vc.addCloseButton()
            
        case let .template(templateViewModel):
           
            //MARK: ContactInputViewController init(117)

            switch templateViewModel.type {
                
            case .direct:
                vc = .init(paymentTemplate: templateViewModel)

            case .contactAdressless:
                vc = .init(paymentTemplate: templateViewModel)
                
            default :
                break
            }
            
            context.coordinator.parentObserver = vc.observe(\.parent, changeHandler: { vc, _ in

                vc.parent?.navigationItem.titleView = vc.navigationItem.titleView
                vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
                vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
            })
        }
        
        vc.modalPresentationStyle = .fullScreen
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ContactInputViewController, context: Context) {}
    
    class Coordinator {
        
        var parentObserver: NSKeyValueObservation?
    }
    
    func makeCoordinator() -> Self.Coordinator { Coordinator() }
}

