//
//  AnywayPaymentEvent.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public enum AnywayPaymentEvent<AnywayResponse>: Equatable
where AnywayResponse: Equatable {
    
    case `continue`
    case fraud(FraudEvent)
    case receivedAnywayResult(AnywayResult)
    case receivedTransferResult(TransferResult)
}

public extension AnywayPaymentEvent {
    
    typealias AnywayResult = Result<AnywayResponse, ServiceFailure>
    
    enum ServiceFailure: Error, Equatable {
        
        case connectivityError
        case serverError(String)
    }
    
    enum FraudEvent: Equatable {
        
        case cancelled, expired
    }
    
    typealias TransferResult = Result<Transaction, TransactionFailure>
}
