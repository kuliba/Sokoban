//
//  UtilityServicePaymentFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

enum UtilityServicePaymentFlowEvent: Equatable {
    
    case dismiss(Dismiss)
    case fraud(FraudEvent)
    case notified(PaymentStateProjection)
}

extension UtilityServicePaymentFlowEvent {
    
    enum Dismiss {
        
        case fullScreenCover
        case fraud
        case paymentError
    }
}
