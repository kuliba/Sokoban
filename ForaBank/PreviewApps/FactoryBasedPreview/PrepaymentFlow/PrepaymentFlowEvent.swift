//
//  PrepaymentFlowEvent.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

enum PrepaymentFlowEvent: Equatable {
    
    case initiated(Initiated)
}

extension PrepaymentFlowEvent {
    
    enum Initiated: Equatable {
        
        case utilityPayment(UtilityPaymentResponse)
    }
}

extension PrepaymentFlowEvent.Initiated {
    
    struct UtilityPaymentResponse: Equatable {
        
        let lastPayments: [LastPayment]
        let operators: [Operator]
    }
}
