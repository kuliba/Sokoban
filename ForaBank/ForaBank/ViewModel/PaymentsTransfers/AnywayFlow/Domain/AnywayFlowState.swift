//
//  AnywayFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2024.
//

struct AnywayFlowState {
    
    let content: Content
    var destination: Destination?
}

extension AnywayFlowState {
    
    typealias Content = AnywayTransactionViewModel
    
    enum Destination: Equatable {
        
        case alert(Alert)
        case completed(Completed)
        case fraud(FraudNoticePayload)
        case main
        
        enum Alert: Equatable {
            
            case paymentRestartConfirmation
            case serverError(String)
            case terminalError(String)
        }
        
        struct Completed: Equatable {
            
            let formattedAmount: String
            let result: TransactionResult
            
            typealias TransactionResult = Result<AnywayTransactionReport, Fraud>
            
            struct Fraud: Equatable, Error {
                
                let hasExpired: Bool
            }
        }
    }
}
