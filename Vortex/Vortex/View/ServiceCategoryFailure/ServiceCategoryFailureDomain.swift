//
//  ServiceCategoryFailureDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 09.12.2024.
//

/// A namespace.
enum ServiceCategoryFailureDomain {}

extension ServiceCategoryFailureDomain {
    
    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    typealias BinderComposer = Vortex.BinderComposer
    
    // MARK: - Content
    
    typealias Content = ServiceCategory
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
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
