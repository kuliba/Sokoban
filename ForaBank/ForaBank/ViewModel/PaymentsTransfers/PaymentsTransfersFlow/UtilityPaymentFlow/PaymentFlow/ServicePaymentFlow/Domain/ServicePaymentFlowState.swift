//
//  ServicePaymentFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.07.2024.
//

import Foundation

enum ServicePaymentFlowState: Equatable {
    
    case none
    case alert(Alert)
    case fraud(FraudNoticePayload)
    case fullScreenCover(Completed)
    case terminated
}

extension ServicePaymentFlowState {
    
    enum Alert: Equatable {
        
        case paymentRestartConfirmation
        case serverError(String)
        case terminalError(String)
    }
    
    typealias Completed = AnywayCompleted
}
