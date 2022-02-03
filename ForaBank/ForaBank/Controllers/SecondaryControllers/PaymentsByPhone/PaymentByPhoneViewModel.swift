//
//  PaymentByPhoneViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 25.01.2022.
//

import Foundation

class PaymentByPhoneViewModel {
    
    var template: PaymentTemplateData?
    var amount: Double?
    var phoneNumber: String?
    var bankId: String = ""
    var selectedBank: BanksList? {
        getBank(id: bankId)
    }
    var maskPhoneNumber: String? {
        guard let phoneNumber = phoneNumber else { return nil }
        var phoneNumberFixed = phoneNumber
        if phoneNumber.count == 10 {
            phoneNumberFixed = "+7" + phoneNumber
        }
        let phoneFormatter = PhoneNumberFormater()
        let formattedPhone = phoneFormatter.format(phoneNumberFixed)
        return formattedPhone
    }
    
    var isSbp: Bool {
        if bankId == "100000000217" {
            return false
        } else {
            return true
        }
    }
    
    func getBank(id: String) -> BanksList? {
        let banksList = Dict.shared.banks
        var bankToReturn: BanksList? = nil
        banksList?.forEach { bank in
            if bank.memberID == id {
                bankToReturn = bank
            }
        }
        return bankToReturn
    }
    
    internal init(phoneNumber: String? = nil, bankId: String = "", amount: Double? = 0) {
        self.phoneNumber = phoneNumber
        self.bankId = bankId
        self.amount = amount
    }
    
    // Init for SPF with Template
    internal init(spf template: PaymentTemplateData) {
        self.template = template
        self.phoneNumber = template.spfPhoneNumber
        self.bankId = template.spfBankId ?? ""
        self.amount = template.spfAmount
        
    }
    
    // Init for Inside bank by phone with Tamplate
    internal init(insideByPhone template: PaymentTemplateData) {
        self.template = template
        self.phoneNumber = template.insideByPhonePhoneNumber
        self.bankId = template.insideByPhoneBankId ?? ""
        self.amount = template.insideByPhoneAmount
        
    }
    
    
}
