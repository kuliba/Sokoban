//
//  BankDefaultEvent.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

public extension FastPaymentsSettingsEvent {
    
    enum BankDefaultEvent: Equatable {
        
        case prepareSetBankDefault
        case setBankDefault
        case setBankDefaultPrepared(ServiceFailure?)
    }
}
