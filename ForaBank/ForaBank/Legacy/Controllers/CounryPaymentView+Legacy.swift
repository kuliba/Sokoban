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
        
        let puref: String
        let country: CountriesList?
        let paymentType: PaymentType
        let bank: BanksList?
        
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
    }
}

struct CountryPaymentView: UIViewControllerRepresentable {
    
    let viewModel: CountryPaymentView.ViewModel
    
    func makeUIViewController(context: Context) -> ContactInputViewController {
        
        let vc = ContactInputViewController()
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
            
        case let .withOutAddress(withOutViewModel):
            
            vc.typeOfPay = .mig
            vc.configure(with: viewModel.country, byPhone: true)
            vc.selectedBank = viewModel.bank
            let mask = StringMask(mask: "+000-0000-00-00")
            let maskPhone = mask.mask(string: withOutViewModel.phoneNumber)
            vc.phoneField.text = maskPhone ?? ""
        }
        
        vc.addCloseButton()
        vc.modalPresentationStyle = .fullScreen
  
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ContactInputViewController, context: Context) {}
}

