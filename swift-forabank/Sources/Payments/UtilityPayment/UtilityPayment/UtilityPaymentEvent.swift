//
//  UtilityPaymentEvent.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public enum UtilityPaymentEvent: Equatable {
    
    case fraud(FraudEvent)
    case receivedTransferResult(TransferResult)
}

public extension UtilityPaymentEvent {
    
    enum FraudEvent: Equatable {
        
        case cancelled, expired
    }
}
