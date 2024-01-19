//
//  FastPaymentsSettingsEvent.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

import Tagged

public enum FastPaymentsSettingsEvent: Equatable {
    
    // General Settings
    case appear
    case loadSettings(UserPaymentSettings)
    case resetStatus
    
    // BankDefault - need better naming in this section
    case prepareSetBankDefault
    case setBankDefault
    case setBankDefaultPrepared(Failure?) // ???
    
    // Contract
    case activateContract
    case deactivateContract
    case updateContract(ContractUpdateResult)
    
    // Products
    case collapseProducts
    case expandProducts
    case updateProduct(ProductUpdateResult)
    case selectProduct(Product)
}

public extension FastPaymentsSettingsEvent {
    
    typealias ContractUpdateResult = Result<UserPaymentSettings.PaymentContract, Failure>
    typealias ProductUpdateResult = Result<Product, Failure>
    
    enum Failure: Error, Equatable {
        
        case connectivityError
        case serverError(String)
    }
}
