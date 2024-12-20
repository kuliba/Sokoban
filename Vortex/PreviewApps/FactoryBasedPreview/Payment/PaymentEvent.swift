//
//  PaymentEvent.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 26.04.2024.
//

enum PaymentEvent: Equatable {
    
    case buttonTapped(PaymentButton)
    case initiated(Initiated)
    case utilityService(UtilityServicePaymentEvent)
}

extension PaymentEvent {
    
    enum Initiated: Equatable {
        
        case utilityPayment(InitiateResponse)
    }
    
    enum PaymentButton: Equatable {
        
        case mobile
        case utilityService
    }
}

extension PaymentEvent.Initiated {
    
    struct InitiateResponse: Equatable {
        
        let lastPayments: [LastPayment]
        let operators: [Operator]
    }
}
