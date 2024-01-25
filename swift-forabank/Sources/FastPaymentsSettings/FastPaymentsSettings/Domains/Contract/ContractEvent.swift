//
//  ContractEvent.swift
//  
//
//  Created by Igor Malyarov on 25.01.2024.
//

public extension FastPaymentsSettingsEvent {
    
    typealias ContractUpdateResult = Result<UserPaymentSettings.PaymentContract, ServiceFailure>
    
    enum ContractEvent: Equatable {
        
        case activateContract
        case deactivateContract
        case updateContract(ContractUpdateResult)
    }
}
