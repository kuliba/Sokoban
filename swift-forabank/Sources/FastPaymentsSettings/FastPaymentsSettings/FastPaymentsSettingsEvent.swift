//
//  FastPaymentsSettingsEvent.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

import Tagged

public enum FastPaymentsSettingsEvent: Equatable {
    
    case activateContract
    case appear
    case collapseProducts
    case contractUpdate(ContractUpdateResult)
    case deactivateContract
    case expandProducts
    case loadedSettings(UserPaymentSettings)
    case prepareSetBankDefault
    case productUpdate(ProductUpdateResult)
    case resetStatus
    case setBankDefaultPrepare(Failure?)
    case setBankDefault
}

public extension FastPaymentsSettingsEvent {
    
    typealias ContractUpdateResult = Result<UserPaymentSettings.PaymentContract, Failure>
    typealias ProductUpdateResult = Result<Product, Failure>
    
    enum Failure: Error, Equatable {
        
        case connectivityError
        case serverError(String)
    }
}
