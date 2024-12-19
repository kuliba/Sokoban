//
//  ServiceCategoryFailureDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 09.12.2024.
//

import PayHub

/// A namespace.
enum ServiceCategoryFailureDomain {}

extension ServiceCategoryFailureDomain {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<Content, Flow>
    typealias BinderComposer = PayHub.BinderComposer
    
    // MARK: - Content
    
    typealias Content = ServiceCategory
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHub.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias Notify = FlowDomain.Notify
    
    enum Select: Equatable {
        
        case detailPayment
        case scanQR
    }
    
    enum Navigation {
        
        case detailPayment(Node<PaymentsViewModel>)
        case scanQR
    }
    
    typealias Destination = FlowDomain.State.Destination
}
