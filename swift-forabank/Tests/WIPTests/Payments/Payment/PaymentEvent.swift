//
//  PaymentEvent.swift
//
//
//  Created by Igor Malyarov on 21.03.2024.
//

enum PaymentEvent: Equatable {
    
    case `continue`
    case parameter(PaymentParameterEvent)
}
