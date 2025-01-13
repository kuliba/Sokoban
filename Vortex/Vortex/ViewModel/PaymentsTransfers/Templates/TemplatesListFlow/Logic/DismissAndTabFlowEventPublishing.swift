//
//  DismissAndTabFlowEventPublishing.swift
//  Vortex
//
//  Created by Igor Malyarov on 10.08.2024.
//

import Combine

protocol DismissAndTabFlowEventPublishing {
    
    var flowEventPublisher: AnyPublisher<DismissAndTabFlowEvent, Never> { get }
}

struct DismissAndTabFlowEvent: Equatable {
    
    let isLoading: Bool
    let status: Status?
    
    init(
        isLoading: Bool = false,
        status: Status? = nil
    ) {
        self.isLoading = isLoading
        self.status = status
    }
    
    enum Status: Equatable {
 
        case dismiss
        case tab(Tab)
        
        enum Tab: Equatable {
            
            case chat, main, payments
        }
    }
}
