//
//  AnywayFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2024.
//

struct AnywayFlowState {
    
    let content: Content
    var status: Status?
}

extension AnywayFlowState {
    
    typealias Content = AnywayTransactionViewModel
    
    enum Status: Equatable {
        
        case alert(Alert)
        case completed(Completed)
        case fraud(FraudNoticePayload)
        case inflight
        case outside(Outside)
        
        enum Alert: Equatable {
            
            case paymentRestartConfirmation
            case serverError(String)
            case terminalError(String)
        }
        
        typealias Completed = AnywayCompleted
        
        enum Outside {
            
            case main
            case payments
        }
    }
}
