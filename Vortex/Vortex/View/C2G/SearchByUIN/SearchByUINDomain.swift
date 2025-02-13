//
//  SearchByUINDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import FlowCore

/// A namespace
enum SearchByUINDomain {}

extension SearchByUINDomain {
    
    // MARK: - Binder
    
    typealias Binder = FlowCore.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = Void
    
    // MARK: - Flow
    
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select: Equatable {
        
        case uin(UIN)
    }
    
    struct UIN: Equatable {
        
        let value: String
    }
    
    enum Navigation {
        
        case failure(BackendFailure)
        case payment(C2GPayment)
        
        typealias C2GPayment = Void
    }
}
