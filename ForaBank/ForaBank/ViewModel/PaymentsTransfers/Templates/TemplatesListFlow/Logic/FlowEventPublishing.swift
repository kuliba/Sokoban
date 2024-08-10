//
//  FlowEventPublishing.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.08.2024.
//

import Combine

protocol FlowEventPublishing {
    
    var flowEventPublisher: AnyPublisher<FlowEvent, Never> { get }
}

enum FlowEvent: Equatable {
    
    case dismiss
    case inflight
    case tab(Tab)
    
    enum Tab: Equatable {
        
        case chat, main, payments
    }
}
