//
//  PaymentParameterEvent.swift
//
//
//  Created by Igor Malyarov on 21.03.2024.
//

enum PaymentParameterEvent: Equatable {
    
    case input(InputParameterEvent)
    case select(SelectParameterEvent)
}
