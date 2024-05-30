//
//  PaymentByPhoneViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 25.01.2022.
//

import Foundation

class PaymentByPhoneViewModel {
    
    let model: Model = .shared
    var template: PaymentTemplateData?
    var amount: Double?
    var phoneNumber: String?
    var bankId: String = ""
    var selectedBank: BanksList? {
        getBank(id: bankId)
    }
    
    var setBackAction: Bool = false
    var closeAction: () -> Void = {}

    var maskPhoneNumber: String? {
        guard let phoneNumber = phoneNumber else { return nil }
        var phoneNumberFixed = phoneNumber
        if phoneNumber.count == 10 {
            phoneNumberFixed = "+7" + phoneNumber
        }
        let phoneFormatter = PhoneNumberKitFormater()
        let formattedPhone = phoneFormatter.format(phoneNumberFixed)
        return formattedPhone
    }
    
    var isSbp: Bool {
        if bankId == BankID.foraBankID.rawValue {
            return false
        } else {
            return true
        }
    }
    
    var userCard: UserAllCardsModel? {
        return getUserCard()
    }
    
    func getBank(id: String) -> BanksList? {
        let banksList = model.dictionaryBankListLegacy
        var bankToReturn: BanksList? = nil
        banksList?.forEach { bank in
            if bank.memberID == id {
                bankToReturn = bank
            }
        }
        return bankToReturn
    }
    
    private func getUserCard() -> UserAllCardsModel?  {
        
        var products: [UserAllCardsModel] = []
        let types: [ProductType] = [.card, .account, .deposit, .loan]
        types.forEach { type in
            products.append(contentsOf: self.model.products.value[type]?.map({ $0.userAllProducts()}) ?? [])
        }
        
        let filterProduct = products.filter({
            ($0.productType == "CARD" || $0.productType == "ACCOUNT") && $0.currency == "RUB" })
        
        if filterProduct.count > 0 {
            if let template = self.template {
                if template.type == .sfp {
                    let card = filterProduct.first(where: { $0.id == template.payerProductId })
                    return card
                } else if template.type == .byPhone {
                    let card = filterProduct.first(where: { $0.id == template.payerProductId })
                    return card
                } else {
                    return filterProduct.first
                }
            } else {
                return filterProduct.first
            }
        }
        return nil
    }
    
    internal init(phoneNumber: String? = nil, bankId: String = "", amount: Double? = 0, closeAction: @escaping () -> Void = {}) {
        self.phoneNumber = phoneNumber
        self.bankId = bankId
        self.amount = amount
        self.closeAction = closeAction
    }
    
    // Init for Inside bank by phone with Tamplate
    internal init(insideByPhone template: PaymentTemplateData, closeAction: @escaping () -> Void ) {
        self.template = template
        self.phoneNumber = template.phoneNumber
        self.bankId = template.foraBankId ?? ""
        self.amount = template.amount
        self.closeAction = closeAction
    }
    
    
}
