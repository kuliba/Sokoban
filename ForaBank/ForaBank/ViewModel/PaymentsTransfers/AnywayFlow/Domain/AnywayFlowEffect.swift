//
//  AnywayFlowEffect.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2024.
//

import Foundation

enum AnywayFlowEffect: Equatable {
    
    case delay(Event, for: DispatchTimeInterval)
}

extension AnywayFlowEffect {
    
    typealias Event = AnywayFlowEvent
}
