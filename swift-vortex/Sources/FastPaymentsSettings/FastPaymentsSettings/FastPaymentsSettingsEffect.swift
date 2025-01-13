//
//  FastPaymentsSettingsEffect.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import Tagged

public enum FastPaymentsSettingsEffect: Equatable {
    
    case consentList(ConsentListEffect)
    case contract(ContractEffect)
    case getSettings
    case prepareDeleteDefaultBank
    case prepareSetBankDefault
    case subscription(SubscriptionEffect)
    case updateProduct(ContractCore)
}

public extension FastPaymentsSettingsEffect {
    
    typealias ContractCore = ContractEffect.ContractCore
}
