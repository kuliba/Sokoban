//
//  FastPaymentsSettingsEffect.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

enum FastPaymentsSettingsEffect: Equatable {
 
    case activateContract(Contract)
    case createContract(ProductID)
    case getUserPaymentSettings
    case prepareSetBankDefault
    case updateProduct(UpdateProductPayload)
}

extension FastPaymentsSettingsEffect {
    
    typealias Contract = UserPaymentSettings.PaymentContract
    typealias ProductID = Product.ID
    typealias UpdateProductPayload = FastPaymentsSettingsEffectHandler.UpdateProductPayload
}
