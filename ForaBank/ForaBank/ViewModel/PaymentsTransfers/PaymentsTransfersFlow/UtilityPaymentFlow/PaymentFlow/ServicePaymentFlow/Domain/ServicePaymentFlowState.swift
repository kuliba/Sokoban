//
//  ServicePaymentFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.07.2024.
//

enum ServicePaymentFlowState: Equatable {
    
    case none
    case alert(Alert)
    case fraud(FraudNoticePayload)
    case fullScreenCover(FullScreenCover)
    case terminated
}

extension ServicePaymentFlowState {

    enum Alert: Equatable {
        
        case paymentRestartConfirmation
        case serverError(String)
        case terminalError(String)
    }
    
    enum FullScreenCover: Equatable {
        
        case completed(TransactionResult)
        
        typealias TransactionResult = Result<AnywayTransactionReport, Fraud>
        
        struct Fraud: Equatable, Error {
            
            let formattedAmount: String
            let hasExpired: Bool
        }
    }
    
    var alert: Alert? {
        
        guard case let .alert(alert) = self
        else { return nil }
        
        return alert
    }
    
    var fraud: FraudNoticePayload? {
        
        guard case let .fraud(fraud) = self
        else { return nil }
        
        return fraud
    }
    
    var fullScreenCover: FullScreenCover? {
        
        guard case let .fullScreenCover(fullScreenCover) = self
        else { return nil }
        
        return fullScreenCover
    }
}
