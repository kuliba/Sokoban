//
//  ProductsLandingDomain.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 11.03.2025.
//

import RxViewModel
import Foundation
import OrderCardLandingComponent

enum ProductsLandingDomain {}

extension ProductsLandingDomain {
    
    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    typealias BinderComposer = Vortex.BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias Landing = [OrderCardLandingComponent.Product]
    
    typealias State = LandingState<Landing>
    typealias Event = LandingEvent<Landing>
    typealias Effect = LandingEffect
    
    typealias Reducer = ProductLandingReducer<Landing>
    typealias EffectHandler = ProductLandingEffectHandler<Landing>
    
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
