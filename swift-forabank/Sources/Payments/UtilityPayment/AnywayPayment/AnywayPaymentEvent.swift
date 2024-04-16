//
//  AnywayPaymentEvent.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public enum AnywayPaymentEvent<Response>: Equatable
where Response: Equatable {
    
    case `continue`
    case fraud(FraudEvent)
    case receivedAnywayResult(AnywayResult)
    case receivedTransferResult(TransferResult)
}

public extension AnywayPaymentEvent {
    
    typealias AnywayResult = Result<Response, ServiceFailure>
    
    enum ServiceFailure: Error, Equatable {
        
        case connectivityError
        case serverError(String)
    }
    
    enum FraudEvent: Equatable {
        
        case cancelled, expired
    }
    
    typealias TransferResult = Result<Transaction, TransactionFailure>
}
