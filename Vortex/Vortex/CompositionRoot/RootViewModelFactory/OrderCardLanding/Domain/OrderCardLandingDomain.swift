//
//  OrderCardLandingDomain.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 25.02.2025.
//

import RxViewModel
import OrderCard

enum OrderCardLandingDomain {}

extension OrderCardLandingDomain {

    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    typealias BinderComposer = Vortex.BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias State = LandingState<OrderCardLanding>
    typealias Event = LandingEvent<OrderCardLanding>
    typealias Effect = LandingEffect
    
    typealias Content = RxViewModel<State, Event, Effect>
    typealias Domain = OrderCardLandingDomain
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias NotifyEvent = FlowDomain.NotifyEvent
    typealias Notify = (NotifyEvent) -> Void
    
    enum Select: Equatable {
        case `continue`
    }
    
    enum Navigation {

        case `continue`
    }
}
