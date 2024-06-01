//
//  UtilityServicePaymentFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

enum UtilityServicePaymentFlowEvent: Equatable {
    
    case dismiss(Dismiss)
    case dismissFraud
    case dismissPaymentError
    case fraud(FraudEvent)
    case notified(PaymentStateProjection)
}

extension UtilityServicePaymentFlowEvent {
    
    enum Dismiss {
        
        case fullScreenCover
    }
}
