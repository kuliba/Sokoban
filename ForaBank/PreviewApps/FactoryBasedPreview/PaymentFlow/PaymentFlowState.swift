//
//  PaymentFlowState.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

struct PaymentFlowState: Equatable {
    
    var destination: Destination?
}

extension PaymentFlowState {
    
    enum Destination: Equatable {
        
        case utilityServicePayment(UtilityPrepaymentState)
    }
}

extension PaymentFlowState.Destination {
    
    struct UtilityPrepaymentState: Equatable {
        
        let lastPayments: [LastPayment]
        let operators: [Operator]
    }
}
