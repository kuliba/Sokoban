//
//  PaymentsEvent.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

enum PaymentsEvent: Equatable {
    
    case dismissDestination
    case payment(PaymentEvent)
}
