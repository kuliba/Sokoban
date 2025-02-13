//
//  C2GPaymentDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import FlowCore

/// A namespace.
enum C2GPaymentDomain {}

extension C2GPaymentDomain {
    
    // MARK: - Binder
    
    typealias Binder = FlowCore.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = Void
    
    // MARK: - Flow
    
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select: Equatable {
        
        case pay(Payload)
        
        typealias Payload = String
    }
    
    enum Navigation {
        
        case failure(BackendFailure)
        case success(Void)
    }
}
