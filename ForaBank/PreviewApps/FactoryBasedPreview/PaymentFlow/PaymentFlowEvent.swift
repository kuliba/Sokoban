//
//  PaymentFlowEvent.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

enum PaymentFlowEvent: Equatable {
    
    case loaded(Loaded)
}

extension PaymentFlowEvent {
    
    enum Loaded: Equatable {
        
        case utilityPayment(UtilityPaymentResponse)
    }
}

extension PaymentFlowEvent.Loaded {
    
    struct UtilityPaymentResponse: Equatable {
        
        let lastPayments: [LastPayment]
        let operators: [Operator]
    }
}
