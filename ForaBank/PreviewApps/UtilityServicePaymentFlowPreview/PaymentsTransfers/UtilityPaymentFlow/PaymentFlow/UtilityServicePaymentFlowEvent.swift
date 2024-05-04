//
//  UtilityServicePaymentFlowEvent.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

enum UtilityServicePaymentFlowEvent: Equatable {
    
    case dismissFraud
    case fraudDetected(Fraud)
    case fraud(FraudEvent)
}

extension UtilityServicePaymentFlowEvent {
    
    typealias Fraud = PaymentFlowState.Modal.Fraud
}
