//
//  MeToMeDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.01.2025.
//

/// A namespace.
enum MeToMeDomain {}

extension MeToMeDomain {
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    typealias NotifyEvent = FlowDomain.NotifyEvent
    
    enum Select {
        
        case alert(String)
        case meToMe
        case successMeToMe(Node<PaymentsSuccessViewModel>)
    }
    
    enum Navigation {
        
        case alert(String)
        case meToMe(Node<PaymentsMeToMeViewModel>)
        case successMeToMe(Node<PaymentsSuccessViewModel>)
    }
}
