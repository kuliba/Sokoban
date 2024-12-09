//
//  ServiceCategoryFailureDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.12.2024.
//

import PayHub
import PayHubUI

/// A namespace.
enum ServiceCategoryFailureDomain {}

extension ServiceCategoryFailureDomain {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<Content, Flow>
    typealias BinderComposer = PayHubUI.BinderComposer
    
    // MARK: - Content
    
    typealias Content = ()
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    enum Select: Equatable {
        
        case detailPayment
    }
    
    enum Navigation {
        
        case detailPayment(PaymentsViewModel)
    }
    
    typealias Destination = Navigation
}
