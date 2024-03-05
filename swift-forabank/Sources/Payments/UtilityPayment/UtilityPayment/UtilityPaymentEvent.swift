//
//  UtilityPaymentEvent.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public enum UtilityPaymentEvent<CreateAnywayTransferResponse: Equatable>: Equatable {
    
    case `continue`
    case fraud(FraudEvent)
    case receivedAnywayResult(AnywayResult)
    case receivedTransferResult(TransferResult)
}

public extension UtilityPaymentEvent {
    
    typealias AnywayResult = Result<CreateAnywayTransferResponse, ServiceFailure>
    
    enum FraudEvent: Equatable {
        
        case cancelled, expired
    }
    
    typealias TransferResult = Result<Transaction, TransactionFailure>
}
