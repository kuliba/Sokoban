//
//  PaymentFlowMockState.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 05.05.2024.
//

struct PaymentFlowMockState: Equatable {
    
    var isComplete: Bool = false
    var fraud: Fraud?
    var errorMessage: String?
}

extension PaymentFlowMockState {
    
    typealias Fraud = UtilityServicePaymentFlowState.Modal.Fraud
}
