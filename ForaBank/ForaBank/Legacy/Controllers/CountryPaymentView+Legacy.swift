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
            
        case let .template(templateViewModel):
           
            //MARK: ContactInputViewController init(117)

            switch templateViewModel.type {
                
            case .direct:
                if let model = templateViewModel.parameterList.first as? TransferAnywayData {
                    let country = vc.getCountry(code: "AM")
                    vc.typeOfPay = .mig
                    vc.configure(with: country, byPhone: true)
                    
                    if let bank = vc.findBankByPuref(purefString: model.puref ?? "") {
                        vc.selectedBank = bank
                        vc.setupBankField(bank: bank)
                    }
                    
                    let mask = StringMask(mask: "+000-0000-00-00")
                    let phone = model.additional.first(where: { $0.fieldname == "RECP" })
                    let maskPhone = mask.mask(string: phone?.fieldvalue)
                    vc.phoneField.text = maskPhone ?? ""
                }
                
            case .contactAdressless:
                if let model = templateViewModel.parameterList.first as? TransferAnywayData {
                    
                    vc.typeOfPay = .contact
                    
                    if let countryCode = model.additional.first(where: { $0.fieldname == "trnPickupPoint" })?.fieldvalue {
                        
                        let country = vc.getCountry(code: countryCode)
                        vc.configure(with: country, byPhone: false)
                        
                        
                    }
                    
                    vc.foraSwitchView.bankByPhoneSwitch.isOn = false
                    vc.foraSwitchView.bankByPhoneSwitch.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    vc.foraSwitchView.bankByPhoneSwitch.thumbTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    
                    if let surName = model.additional.first(where: { $0.fieldname == "bName" })?.fieldvalue {
                        vc.surnameField.text = surName
                    }
                    
                    if let firstName = model.additional.first(where: { $0.fieldname == "bLastName" })?.fieldvalue {
                        vc.nameField.text = firstName
                    }
                    
                    if let middleName = model.additional.first(where: { $0.fieldname == "bSurName" })?.fieldvalue {
                        vc.secondNameField.text = middleName
                    }
                    
                    if let phone = model.additional.first(where: { $0.fieldname == "bPhone" })?.fieldvalue {
                        vc.phoneField.text = phone
                    }
                }
                
            default :
                break
            }
        }
        
        vc.addCloseButton()
        vc.modalPresentationStyle = .fullScreen
  
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ContactInputViewController, context: Context) {}
}

