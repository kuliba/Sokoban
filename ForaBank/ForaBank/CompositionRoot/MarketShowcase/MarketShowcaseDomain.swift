//
//  MarketShowcaseDomain.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 25.09.2024.
//

import LandingMapping
import MarketShowcase
import PayHub
import RxViewModel

enum MarketShowcaseDomain {}

extension MarketShowcaseDomain{
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias ContentState = MarketShowcaseContentState<Landing>
    typealias ContentEvent = MarketShowcaseContentEvent<Landing>
    typealias ContentEffect = MarketShowcaseContentEffect
    
    typealias ContentReducer = MarketShowcaseContentReducer<Landing>
    typealias ContentEffectHandler = MarketShowcaseContentEffectHandler<Landing>
    typealias ContentMicroService = MarketShowcaseContentEffectHandlerMicroServices<Landing>
    
    typealias Content = RxViewModel<ContentState, ContentEvent, ContentEffect>
    
    typealias Landing = LandingMapping.Landing
    
    // MARK: - Flow
    
    typealias FlowState = MarketShowcaseFlowState< Destination, InformerPayload>
    typealias FlowEvent = MarketShowcaseFlowEvent<Destination, InformerPayload>
    typealias FlowEffect = MarketShowcaseFlowEffect
    
    typealias FlowReducer = MarketShowcaseFlowReducer<Destination, InformerPayload>
    typealias FlowEffectHandler = MarketShowcaseFlowEffectHandler<Destination, InformerPayload>
    typealias FlowMicroService = MarketShowcaseFlowEffectHandlerMicroServices<Destination, InformerPayload>
    
    typealias Flow = RxViewModel<FlowState, FlowEvent, FlowEffect>
    
    typealias Destination = Void
    typealias InformerPayload = Void
}
