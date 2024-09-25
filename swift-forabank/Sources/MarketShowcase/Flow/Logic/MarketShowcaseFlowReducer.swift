//
//  MarketShowcaseFlowReducer.swift
//  
//
//  Created by Andryusina Nataly on 25.09.2024.
//

public final class MarketShowcaseFlowReducer<Destination, InformerPayload> {
    
    public init() {}
}

public extension MarketShowcaseFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .destination(destination):
            state.status = .destination(destination)
          
        case let .failure(kind):
            switch kind {
            case let .timeout(informerPayload):
                state.status = .informer(informerPayload)
            case let .error(message):
                state.status = .alert(message)
            }
        case .reset:
            state.status = nil
            
        case let .select(select):
            
            switch select {
            case .goToMain:
                state.status = .outside(.main)
            case .orderSticker:
                effect = .select(.orderSticker)
            case .orderCard:
                effect = .select(.orderCard)
            case let .openURL(url):
                state.status = .outside(.openURL(url))
            }
        }
        
        return (state, effect)
    }
}

public extension MarketShowcaseFlowReducer {
    
    typealias State = MarketShowcaseFlowState< Destination, InformerPayload>
    typealias Event = MarketShowcaseFlowEvent<Destination, InformerPayload>
    typealias Effect = MarketShowcaseFlowEffect
}
