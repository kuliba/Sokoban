//
//  OrderCardLandingDomain.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 25.02.2025.
//

import RxViewModel
import OrderCard
import OrderCardLandingComponent

enum OrderCardLandingDomain {}

extension OrderCardLandingDomain {

    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    typealias BinderComposer = Vortex.BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias Landing = OrderCardLanding
    
    typealias State = LandingState<Landing>
    typealias Event = LandingEvent<Landing>
    typealias Effect = LandingEffect
    
    typealias Reducer = LandingReducer<Landing>
    typealias EffectHandler = LandingEffectHandler<Landing>
    
    typealias Content = RxViewModel<State, Event, Effect>
    
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
