//
//  CardLandingDomain.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 11.03.2025.
//

import OrderCardLandingComponent
import RxViewModel

enum CardLandingDomain {}

extension CardLandingDomain {
    
    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    typealias BinderComposer = Vortex.BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias Landing = [OrderCardLandingComponent.Product]
    
    typealias ContentDomain = CardLandingContentDomain<Landing>
    typealias Content = ContentDomain.Content
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias NotifyEvent = FlowDomain.NotifyEvent
    typealias Notify = (NotifyEvent) -> Void
    
    enum Select: Equatable {
        
        case `continue`
    }
    
    enum Navigation {

        case order(OpenCardDomain.Binder)
    }
}
