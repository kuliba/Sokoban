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
        var operatorsViewModel: OperatorsViewModel?
        
        struct AddressViewModel {
            
            let firstName: String
            let middleName: String
            let surName: String
        }
        
        struct WithOutAddress {
            
            let phoneNumber: String?
        }
        
        struct TurkeyWithOutAddress {
            
            let firstName: String
            let middleName: String
            let surName: String
            let phoneNumber: String
        }
        
        enum PaymentType {
            
            case turkeyWithOutAddress(turkeyWithOutAddress: TurkeyWithOutAddress)
            case address(adressViewModel: AddressViewModel)
            case withOutAddress(withOutViewModel: WithOutAddress)
            case template(templateViewModel: PaymentTemplateData)
        }
        
        init(countryData: PaymentCountryData, operatorsViewModel: OperatorsViewModel) {
            self.operatorsViewModel = operatorsViewModel
            
            if countryData.countryCode == "TR" {
                
                paymentType = .turkeyWithOutAddress(turkeyWithOutAddress: .init(firstName: countryData.firstName ?? "", middleName: countryData.middleName ?? "", surName: countryData.surName ?? "", phoneNumber: countryData.phoneNumber ?? ""))
                
            } else {
                
                if let phoneNumber = countryData.phoneNumber {
                    
                    paymentType = .withOutAddress(withOutViewModel: .init(phoneNumber: phoneNumber))
                    
                } else {
                    
                    paymentType = .address(adressViewModel: .init(firstName: countryData.firstName ?? "", middleName: countryData.middleName ?? "", surName: countryData.surName ?? ""))
                }
            }

            self.puref = countryData.puref
            self.country = Model.shared.dictionaryCountry(for: countryData.countryCode)?.getCountriesList()
            self.bank = Self.findBankByPuref(purefString: countryData.puref)
        }
        
        init(operatorsViewModel: OperatorsViewModel) {
            
            var paymantTemplate: PaymentTemplateData? {
                guard case .template(let paymantTemplate) = operatorsViewModel.mode else { return nil}
                return paymantTemplate
            }
            
            self.operatorsViewModel = operatorsViewModel
            self.paymentTemplate = paymantTemplate
            self.paymentType = .template(templateViewModel: paymantTemplate!)
            self.puref = nil
            self.country = nil
            self.bank = nil
        }
        
        init(paymentTemplate: PaymentTemplateData) {
            
            self.paymentTemplate = paymentTemplate
            self.paymentType = .template(templateViewModel: paymentTemplate)
            self.puref = nil
            self.country = nil
            self.bank = nil
        }
        
        init(country: String, operatorsViewModel: OperatorsViewModel, paymentType: PaymentType) {
            
            self.paymentTemplate = nil
            self.paymentType = paymentType
            self.puref = nil
            self.country = Self.getCountry(code: country)
            self.bank = nil
            self.operatorsViewModel = operatorsViewModel
        }
        
        private static func getCountry(code: String) -> CountriesList? {
            
            let model = Model.shared
            var countryValue: CountriesList?
            let list = model.countriesList.value.map { $0.getCountriesList() }
            list.forEach({ country in
                if country.code == code || country.contactCode == code {
                    countryValue = country
                }
            })
            return countryValue
        }
        
        private static func findBankByPuref(purefString: String) -> BanksList? {
            let model = Model.shared
            let paymentSystems = model.paymentSystemList.value.map { $0.getPaymentSystem() }
            let bankList = model.bankList.value.map { $0.getBanksList() }
            var bankForReturn: BanksList?
            paymentSystems.forEach({ paymentSystem in
                if paymentSystem.code == "DIRECT" {
                    let purefList = paymentSystem.purefList
                    purefList?.forEach({ puref in
                        puref.forEach({ (key, value) in
                            value.forEach { purefList in
                                if purefList.puref == purefString {
                                    bankList.forEach({ bank in
                                        if bank.memberID == key {
                                            bankForReturn = bank
                                        }
                                    })
                                }
                            }
                        })
                    })
                }
            })
            return bankForReturn
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
            
        case let .turkeyWithOutAddress(turkeyWithOutAddress):
            
            vc.typeOfPay = .contact
            vc.foraSwitchView.bankByPhoneSwitch.isOn = false
            vc.foraSwitchView.bankByPhoneSwitch.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            vc.foraSwitchView.bankByPhoneSwitch.thumbTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            vc.nameField.text = turkeyWithOutAddress.firstName
            vc.surnameField.text = turkeyWithOutAddress.surName
            vc.secondNameField.text = turkeyWithOutAddress.middleName
            vc.phoneField.text = "+\(turkeyWithOutAddress.phoneNumber)"
            vc.operatorsViewModel = viewModel.operatorsViewModel
        
        case let .address(adressViewModel):
            
            vc.typeOfPay = .contact
            vc.foraSwitchView.bankByPhoneSwitch.isOn = false
            vc.foraSwitchView.bankByPhoneSwitch.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            vc.foraSwitchView.bankByPhoneSwitch.thumbTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            vc.configure(with: viewModel.country, byPhone: false)
            vc.nameField.text = adressViewModel.firstName
            vc.surnameField.text = adressViewModel.surName
            vc.secondNameField.text = adressViewModel.middleName
            vc.operatorsViewModel = viewModel.operatorsViewModel
            
        case let .withOutAddress(withOutViewModel):
            
            vc.typeOfPay = .mig
            vc.configure(with: viewModel.country, byPhone: true)
            if let bank = viewModel.bank {
                vc.selectedBank = bank
                vc.setupBankField(bank: bank)
            }
            vc.phoneField.text = "+\(withOutViewModel.phoneNumber ?? "")"
            vc.operatorsViewModel = viewModel.operatorsViewModel
            
        case let .template(templateViewModel):
           
            //MARK: ContactInputViewController init(117)

            switch templateViewModel.type {
            case .direct:
                vc = .init(paymentTemplate: templateViewModel)
                vc.operatorsViewModel = viewModel.operatorsViewModel
            case .contactAdressless:
                vc = .init(paymentTemplate: templateViewModel)
                vc.operatorsViewModel = self.viewModel.operatorsViewModel
            default :
                break
            }
            
        }
        context.coordinator.parentObserver = vc.observe(\.parent, changeHandler: { vc, _ in
            
            vc.parent?.navigationItem.titleView = vc.navigationItem.titleView
            vc.parent?.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem
            vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
        })
        
        vc.modalPresentationStyle = .fullScreen
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ContactInputViewController, context: Context) {}
    
    class Coordinator {
        
        var parentObserver: NSKeyValueObservation?
    }
    
    func makeCoordinator() -> Self.Coordinator { Coordinator() }
}

