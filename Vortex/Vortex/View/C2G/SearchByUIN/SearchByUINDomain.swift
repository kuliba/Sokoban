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
    
    typealias Content = RxInputViewModel
    
    // MARK: - Flow
    
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select: Equatable {
        
        case uin(UIN)
        
        typealias UIN =  String
    }
    
    typealias Navigation = C2GPaymentResult
    
    typealias C2GPaymentResult = Result<C2GPayment, BackendFailure>
    typealias C2GPayment = C2GPaymentDomain.Binder
}
