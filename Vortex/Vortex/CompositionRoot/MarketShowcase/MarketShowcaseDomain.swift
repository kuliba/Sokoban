//
//  MarketShowcaseDomain.swift
//  Vortex
//
//  Created by Andryusina Nataly on 25.09.2024.
//

import LandingMapping
import MarketShowcase
import RxViewModel

enum MarketShowcaseDomain {}

extension MarketShowcaseDomain{
    
    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias ContentState = MarketShowcaseContentState<Landing, InformerPayload>
    typealias ContentStatus = MarketShowcaseContentStatus<Landing, InformerPayload>
    typealias ContentEvent = MarketShowcaseContentEvent<Landing, InformerPayload>
    typealias ContentEffect = MarketShowcaseContentEffect
    typealias ContentError = MarketShowcase.BackendFailure< InformerPayload>
    
    typealias ContentReducer = MarketShowcaseContentReducer<Landing, InformerPayload>
    typealias ContentEffectHandler = MarketShowcaseContentEffectHandler<Landing, InformerPayload>
    typealias ContentMicroService = MarketShowcaseContentEffectHandlerMicroServices<Landing, InformerPayload>
    
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
    typealias InformerPayload = InformerData
}
