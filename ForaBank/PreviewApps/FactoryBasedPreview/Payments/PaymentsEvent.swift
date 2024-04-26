//
//  PaymentsEvent.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

enum PaymentsEvent: Equatable {
    
    case buttonTapped(ButtonTapped)
    case dismissDestination
    case payment(PaymentEvent)
}

extension PaymentsEvent {
    
    #warning("move `CaseIterable` to UI matching type")
    enum ButtonTapped: CaseIterable {
        
        case mobile
        case utilityService
    }
}
