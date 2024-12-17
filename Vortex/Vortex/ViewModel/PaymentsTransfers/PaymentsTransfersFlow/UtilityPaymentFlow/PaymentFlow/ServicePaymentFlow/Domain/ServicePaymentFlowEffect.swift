//
//  ServicePaymentFlowEffect.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.07.2024.
//

import Foundation

enum ServicePaymentFlowEffect: Equatable {
    
    case delay(Event, for: DispatchTimeInterval)
}

extension ServicePaymentFlowEffect {
    
    typealias Event = ServicePaymentFlowEvent
}
