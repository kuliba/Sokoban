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
    case loadSettings(UserPaymentSettingsResult)
    case resetStatus
    
    case bankDefault(BankDefaultEvent)
    case consentList(ConsentListEvent)
    case contract(ContractEvent)
    case products(ProductsEvent)
    case subscription(SubscriptionEvent)
    case accountLinking
}
