//
//  UtilityServicePaymentFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import AnywayPaymentDomain

enum UtilityServicePaymentFlowEvent: Equatable {
    
    case dismiss(Dismiss)
    case fraud(FraudEvent)
    case notified(AnywayTransactionStatus?)
    case showResult(TransactionResult)
}

extension UtilityServicePaymentFlowEvent {
    
    enum Dismiss {
        
        case fullScreenCover
        case fraud
        case paymentError
    }
    
    typealias TransactionResult = AnywayTransactionStatus.TransactionResult
}
