//
//  PaymentsEvent.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

enum PaymentsEvent: Equatable {
    
    case buttonTapped(ButtonTapped)
    case dismissDestination
    case paymentFlow(PaymentFlowEvent)
}

extension PaymentsEvent {
    
    enum ButtonTapped: CaseIterable {
        
        case mobile
        case utilityService
    }
}
