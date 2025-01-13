//
//  ChooseCountryHeaderViewModel.swift
//  Vortex
//
//  Created by Mikhail on 19.07.2021.
//

import UIKit

struct ChooseCountryHeaderViewModel {
    
    let surName: String?
    let firstName: String?
    let middleName: String?
    let shortName: String?
    let countryName: String
    let countryCode: String
    let puref: String
    let phoneNumber: String?
    var country: CountriesList?
    var countryImage: UIImage?
    var bank: BanksList?

    private let model = Model.shared
    
    init(model: GetPaymentCountriesDatum) {
        self.countryName = model.countryName ?? ""
        self.countryCode = model.countryCode ?? ""
        self.puref = model.puref ?? ""
        self.shortName = model.shortName
        
        self.phoneNumber = model.phoneNumber
        self.surName = model.surName
        self.firstName = model.firstName
        self.middleName = model.middleName
        setCountry(code: model.countryCode ?? "")
        findBankByPuref(purefString: puref)
    }
    
    private mutating func setCountry(code: String) {
        let countries = model.countriesList.value
        let countriesList = countries.map { $0.getCountriesList() }
        countriesList.forEach({ country in
            if country.code == countryCode {
                self.country = country
                self.countryImage = country.svgImage?.convertSVGStringToImage()
            }
        })
    }
    
    private mutating func findBankByPuref(purefString: String) {
        let paymentSystems = model.paymentSystemList.value.map { $0.getPaymentSystem() }
        let bankList = model.bankList.value.map { $0.getBanksList() }
        paymentSystems.forEach({ paymentSystem in
            if paymentSystem.code == "DIRECT" {
                let purefList = paymentSystem.purefList
                purefList?.forEach({ puref in
                    puref.forEach({ (key, value) in
                        value.forEach { purefList in
                            if purefList.puref == purefString {
                                bankList.forEach({ bank in
                                    if bank.memberID == key {
                                        self.bank = bank
                                    }
                                })
                            }
                        }
                    })
                })
            }
        })
    }

    
}

