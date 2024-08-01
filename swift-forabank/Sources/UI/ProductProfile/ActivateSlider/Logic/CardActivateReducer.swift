//
//  CardActivateReducer.swift
//
//
//  Created by Andryusina Nataly on 28.02.2024.
//

import Combine
import Foundation
import RxViewModel

public final class CardActivateReducer {
    
    private let cardReduce: CardReduce
    private let sliderReduce: SliderReduce
    private let alertLifespan: DispatchTimeInterval

    private let maxOffset: CGFloat
    
    public init(
        cardReduce: @escaping CardReduce,
        sliderReduce: @escaping SliderReduce,
        alertLifespan: DispatchTimeInterval = .milliseconds(200),
        maxOffset: CGFloat
    ) {
        self.cardReduce = cardReduce
        self.sliderReduce = sliderReduce
        self.alertLifespan = alertLifespan
        self.maxOffset = maxOffset
    }
    
    public func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .card(cardEvent):
            let (cardState, cardEffect) = cardReduce(state.cardState, cardEvent)
            state.cardState = cardState
            if cardState == .status(nil) {
                state.offsetX = 0
            }

            if let cardEffect {
                effect = .card(cardEffect)
            }
        case let .slider(payload, sliderEvent):
            let (sliderState, _) = sliderReduce(state.offsetX, sliderEvent)
            state.offsetX = sliderState
            if sliderState >= maxOffset {
                effect = .card(.confirmation(payload, alertLifespan))
            }
        }
        
        return (state, effect)
    }
    
    public typealias State = CardActivateState
    public typealias Event = CardActivateEvent
    public typealias Effect = CardActivateEffect
    
    public typealias SliderState = CGFloat
    
    public typealias CardReduce = (CardState, CardEvent) -> (CardState, CardEffect?)
    public typealias SliderReduce = (SliderState, SliderEvent) -> (SliderState, Never?)
}

public typealias ActivateSliderViewModel = RxViewModel<CardActivateState, CardActivateEvent, CardActivateEffect>

public extension CardActivateReducer {
    
    static let `default` = CardActivateReducer.reduce(
        .init(
            cardReduce: CardReducer().reduce(_:_:),
            sliderReduce: SliderReducer(maxOffsetX: .maxOffsetX).reduce(_:_:),
            maxOffset: .maxOffsetX)
    )
}
