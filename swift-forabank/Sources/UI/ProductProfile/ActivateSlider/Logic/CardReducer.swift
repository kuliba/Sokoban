//
//  CardReducer.swift
//
//
//  Created by Andryusina Nataly on 22.02.2024.
//

import Foundation

public final class CardReducer {
    
    private let sliderLifespan: DispatchTimeInterval
    
    public init(
        sliderLifespan: DispatchTimeInterval = .seconds(1)
    ) {
        self.sliderLifespan = sliderLifespan
    }
}

public extension CardReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch state {
            
        case .active:
            break
            
        case .status:
            switch event {
            case let .activateCard(payload):
                state = .status(.confirmActivate(payload)) // alert
                
            case let .activateCardResponse(response):
                switch response {
                case .connectivityError, .serverError:
                    state = .status(nil)
                case .success:
                    state = .status(.activated)
                    effect = .dismiss(sliderLifespan)
                }
                
            case let .confirmActivate(tap):
                switch tap {
                case let .activate(payload):
                    state = .status(.inflight)
                    effect = .activate(payload)
                case .cancel:
                    state = .status(nil)
                }
                
            case .dismissActivate:
                state = .active
            }
        }
        
        return (state, effect)
    }
}

public extension CardReducer {
    
    typealias State = CardState
    typealias Event = CardEvent
    typealias Effect = CardEffect
    
    typealias Reduce = (State, Event) -> (State, Effect?)
}
