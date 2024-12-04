//
//  FlowReducer.swift
//  
//
//  Created by Andryusina Nataly on 04.12.2024.
//

public final class FlowReducer<Destination, InformerPayload> {
    
    public init() {}
}

public extension FlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case let .destination(destination):
            state.status = .destination(destination)
          
        case let .failure(kind):
            switch kind {
            case let .timeout(informerPayload):
                state.status = .informer(informerPayload)
            case let .error(message):
                state.status = .alert(.init(message: message))
            }
        case .reset:
            state.status = nil
            
        case let .select(select):
            
            switch select {
            case .goToMain:
                state.status = .outside(.main)
            case .order:
                state.status = .outside(.order)
            }
        }
        
        return (state, .none)
    }
}

public extension FlowReducer {
    
    typealias State = FlowState<Destination, InformerPayload>
    typealias Event = FlowEvent<Destination, InformerPayload>
    typealias Effect = FlowEffect
}
