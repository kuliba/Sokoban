//
//  PrepaymentFlowEvent.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

enum PrepaymentFlowEvent: Equatable {
    
    case loaded(Loaded)
}

extension PrepaymentFlowEvent {
    
    enum Loaded: Equatable {
        
        case utilityPayment(UtilityPaymentResponse)
    }
}

extension PrepaymentFlowEvent.Loaded {
    
    struct UtilityPaymentResponse: Equatable {
        
        let lastPayments: [LastPayment]
        let operators: [Operator]
    }
}
