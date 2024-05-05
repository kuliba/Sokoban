//
//  PaymentFlowMockState.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 05.05.2024.
//

struct PaymentFlowMockState: Equatable {
    
    var fraud: Fraud?
    var errorMessage: String?
}

extension PaymentFlowMockState {
    
    typealias Fraud = PaymentFlowState.Modal.Fraud
}
