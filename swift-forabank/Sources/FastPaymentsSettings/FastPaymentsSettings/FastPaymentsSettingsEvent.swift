//
//  FastPaymentsSettingsEvent.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

import Tagged

public enum FastPaymentsSettingsEvent: Equatable {
    
    // Account Linking
    case accountLinking
    case loadedGetC2BSub(GetC2BSubResult)
    
    // General Settings
    case appear
    case loadSettings(UserPaymentSettings)
    case resetStatus
    
    case bankDefault(BankDefault)
    case consentList(ConsentListEvent)
    case contract(Contract)
    case products(Products)
}

public extension FastPaymentsSettingsEvent {
    
    typealias GetC2BSubResult = Result<GetC2BSubResponse, Failure>
}

public extension FastPaymentsSettingsEvent {
    
    typealias ContractUpdateResult = Result<UserPaymentSettings.PaymentContract, Failure>
    typealias ProductUpdateResult = Result<Product.ID, Failure>
    
    enum BankDefault: Equatable {
        
        case prepareSetBankDefault
        case setBankDefault
        case setBankDefaultPrepared(Failure?)
    }
    
    enum Contract: Equatable {
        
        case activateContract
        case deactivateContract
        case updateContract(ContractUpdateResult)
    }
    
#warning("extract as `FastPaymentsFailure/ServiceFailure`")
    enum Failure: Error, Equatable {
        
        case connectivityError
        case serverError(String)
    }
    
    enum Products: Equatable {
        
        case selectProduct(Product.ID)
        case toggleProducts
        case updateProduct(ProductUpdateResult)
    }
}
