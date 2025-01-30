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
    
    typealias Content = Int
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    typealias NotifyEvent = FlowDomain.NotifyEvent
    
    enum Select {
        
        case alert(String)
        case meToMe
        case openProduct
        case successMeToMe(Node<PaymentsSuccessViewModel>)
    }
    
    enum Navigation {
        
        case alert(String)
        case meToMe(Node<PaymentsMeToMeViewModel>)
        case openProduct(String)
        case successMeToMe(Node<PaymentsSuccessViewModel>)
    }
}
