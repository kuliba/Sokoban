//
//  AnywayFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2024.
//

enum AnywayFlowEvent: Equatable {
    
    case notify(AnywayTransactionStatus?)
    case showResult(TransactionResult)
}

extension AnywayFlowEvent {
    
    typealias TransactionResult = Result<AnywayTransactionReport, Fraud>

    struct Fraud: Equatable, Error {
        
        let formattedAmount: String
        let hasExpired: Bool
    }
}
