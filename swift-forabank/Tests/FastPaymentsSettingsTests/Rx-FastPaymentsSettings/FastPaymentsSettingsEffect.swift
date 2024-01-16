//
//  FastPaymentsSettingsEffect.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

enum FastPaymentsSettingsEffect: Equatable {
 
    case getUserPaymentSettings
    case activateContract(Contract)
    case prepareSetBankDefault
    case createContract(Product.ID)
}

extension FastPaymentsSettingsEffect {
    
    typealias Contract = UserPaymentSettings.PaymentContract
}
