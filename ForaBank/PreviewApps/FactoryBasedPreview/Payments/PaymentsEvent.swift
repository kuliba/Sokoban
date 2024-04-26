//
//  PaymentsEvent.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

enum PaymentsEvent: Equatable {
    
    case dismissDestination
#warning("find a way to decouple from PaymentEvent")
    case payment(PaymentEvent)
    case paymentButtonTapped(PaymentButton)
}

extension PaymentsEvent {
    
    enum PaymentButton {
        
        case mobile
        case utilityService
    }
}
