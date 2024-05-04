//
//  UtilityServicePaymentFlowEvent.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

enum UtilityServicePaymentFlowEvent: Equatable {
    
    case dismissFraud
    case fraud(Fraud)
}

extension UtilityServicePaymentFlowEvent {
    
    typealias Fraud = PaymentFlowState.Modal.Fraud
}
