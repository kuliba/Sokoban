//
//  PrepaymentFlowState.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

struct PrepaymentFlowState: Equatable {
    
    var destination: Destination?
}

extension PrepaymentFlowState {
    
    enum Destination: Equatable {
        
        case utilityServicePayment(UtilityPrepaymentState)
    }
}

extension PrepaymentFlowState.Destination {
    
    struct UtilityPrepaymentState: Equatable {
        
        let lastPayments: [LastPayment]
        let operators: [Operator]
    }
}
