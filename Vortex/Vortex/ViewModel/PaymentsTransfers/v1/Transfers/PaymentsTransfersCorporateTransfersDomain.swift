//
//  PaymentsTransfersCorporateTransfersDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.01.2025.
//

/// A namespace.
enum PaymentsTransfersCorporateTransfersDomain {}

extension PaymentsTransfersCorporateTransfersDomain {
    
    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = Void
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select {
        
        case meToMe
        case openProduct
    }
    
    enum Navigation {
        
        case meToMe(String)
        case openProduct(String)
    }
}
