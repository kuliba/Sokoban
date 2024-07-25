//
//  ServicePaymentFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.07.2024.
//

import AnywayPaymentDomain
import AnywayPaymentUI

enum ServicePaymentFlowEvent: Equatable {
    
    case notify(TransactionProjection)
    case showResult(TransactionResult)
}

extension ServicePaymentFlowEvent {
    
    struct TransactionProjection: Equatable {
        
        let context: AnywayPaymentContext
        let status: AnywayTransactionStatus?
    }
    
    typealias TransactionResult = Result<AnywayTransactionReport, Fraud>
    
    struct Fraud: Equatable, Error {
        
        let formattedAmount: String
        let hasExpired: Bool
    }
}
