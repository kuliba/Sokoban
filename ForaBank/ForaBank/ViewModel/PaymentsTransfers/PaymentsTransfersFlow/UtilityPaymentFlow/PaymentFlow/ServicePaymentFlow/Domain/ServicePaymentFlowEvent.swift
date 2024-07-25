//
//  ServicePaymentFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.07.2024.
//

enum ServicePaymentFlowEvent: Equatable {
    
    case notify(Status?)
    case showResult(TransactionResult)
}

extension ServicePaymentFlowEvent {
    
    typealias TransactionResult = Result<AnywayTransactionReport, Fraud>

    struct Fraud: Equatable, Error {
        
        let formattedAmount: String
        let hasExpired: Bool
    }

    typealias Status = AnywayTransactionStatus
}
