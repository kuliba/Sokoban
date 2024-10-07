//
//  CarouselBaseReducer.swift
//  
//
//  Created by Andryusina Nataly on 07.10.2024.
//

public final class CarouselBaseReducer {
    
    public init() {}
}

public extension CarouselBaseReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .card(cardAction):
            switch cardAction {
            case .goToMain:
                effect = .goToMain
                
            case let .openUrl(link):
                effect = .openUrl(link)
            default:
                break
            }

        default:
            break
        }
        return (state, effect)
    }
}

public extension CarouselBaseReducer {
    
    typealias State = CarouselBaseState
    typealias Event = LandingEvent
    typealias Effect = CarouselEffect
}
