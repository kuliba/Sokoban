//
//  UtilityServicePaymentEvent.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 26.04.2024.
//

enum UtilityServicePaymentEvent: Equatable {
    
    case initiated(InitiateResponse)
    case prepayment(UtilityServicePrepaymentEvent)
}

extension UtilityServicePaymentEvent {
    
    struct InitiateResponse: Equatable {
        
        let lastPayments: [LastPayment]
        let operators: [Operator]
    }
}
