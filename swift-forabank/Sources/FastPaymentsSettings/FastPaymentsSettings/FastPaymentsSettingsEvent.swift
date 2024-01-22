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
    
    case bankDefault(BankDefault)
    case contract(Contract)
    case products(Products)
}

public extension FastPaymentsSettingsEvent {
    
    typealias ContractUpdateResult = Result<UserPaymentSettings.PaymentContract, Failure>
    typealias ProductUpdateResult = Result<Product, Failure>
    
    // BankDefault - need better naming in this section
    enum BankDefault: Equatable {
        
        case prepareSetBankDefault
        case setBankDefault
        case setBankDefaultPrepared(Failure?) // ???
    }
    
    enum Contract: Equatable {
        
        case activateContract
        case deactivateContract
        case updateContract(ContractUpdateResult)
    }
    
#warning("extract as `FastPaymentsFailure`")
    enum Failure: Error, Equatable {
        
        case connectivityError
        case serverError(String)
    }
    
    enum Products: Equatable {
        
        case collapseProducts
        case expandProducts
        case updateProduct(ProductUpdateResult)
        case selectProduct(Product)
    }
}
