//
//  FastPaymentsSettingsEvent.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

import Tagged

public enum FastPaymentsSettingsEvent: Equatable {
    
    case appear
    case loadedSettings(UserPaymentSettings)
    case contractUpdate(ContractUpdateResult)
    
    case productUpdate(ProductUpdateResult)
    
    case setBankDefaultPrepare(Failure?)
    
    case activateContract
    case deactivateContract
#warning("rename case to reflect meaning")
    case resetStatus
    case setBankDefault
    case prepareSetBankDefault
    case confirmSetBankDefault
}

public extension FastPaymentsSettingsEvent {
    
    typealias ContractUpdateResult = Result<UserPaymentSettings.PaymentContract, Failure>
    typealias ProductUpdateResult = Result<Product, Failure>
    
    enum Failure: Error, Equatable {
        
        case connectivityError
        case serverError(String)
    }
}
