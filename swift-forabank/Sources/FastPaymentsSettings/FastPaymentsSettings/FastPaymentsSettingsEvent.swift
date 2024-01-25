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
    case consentList(ConsentListEvent)
    case contract(Contract)
    case products(Products)
    case subscriptions(Subscriptions)
}

public extension FastPaymentsSettingsEvent {
    
    typealias GetC2BSubResult = Result<GetC2BSubResponse, ServiceFailure>
}

public extension FastPaymentsSettingsEvent {
    
    typealias ContractUpdateResult = Result<UserPaymentSettings.PaymentContract, ServiceFailure>
    typealias ProductUpdateResult = Result<Product.ID, ServiceFailure>
    
    enum BankDefault: Equatable {
        
        case prepareSetBankDefault
        case setBankDefault
        case setBankDefaultPrepared(ServiceFailure?)
    }
    
    enum Contract: Equatable {
        
        case activateContract
        case deactivateContract
        case updateContract(ContractUpdateResult)
    }
    
    enum Products: Equatable {
        
        case selectProduct(Product.ID)
        case toggleProducts
        case updateProduct(ProductUpdateResult)
    }
    
    enum Subscriptions: Equatable {
        
        case getC2BSubButtonTapped
        case loaded(GetC2BSubResult)
    }
}
