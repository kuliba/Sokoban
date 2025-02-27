//
//  CreditCardMVPDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.02.2025.
//

import FlowCore
import RxViewModel

/// A namespace.
enum CreditCardMVPDomain {}

extension CreditCardMVPDomain {
    
    // MARK: - Binder
    
    typealias Binder = FlowCore.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = RxViewModel<State, Event, Effect>
    
    // MARK: - Flow
    
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select {
        
        case order(OrderPayload)
        
        struct OrderPayload: Equatable {
            
            let otp: String
        }
    }
    
    enum Navigation {
        
        case complete(Complete)
        
        typealias Complete = Void
    }
}

extension CreditCardMVPDomain {
    
    struct State: Equatable {
        
        var otp: String
    }
    
    enum Event: Equatable {
        
        case otp(String)
    }
    
    enum Effect: Equatable {}
}
