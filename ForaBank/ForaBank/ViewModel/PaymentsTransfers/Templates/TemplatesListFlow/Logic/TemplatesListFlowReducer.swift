//
//  TemplatesListFlowReducer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.08.2024.
//

final class TemplatesListFlowReducer<Content> {}

extension TemplatesListFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        let effect = reduce(&state, event)
        
        return (state, effect)
    }
}

extension TemplatesListFlowReducer {
    
    typealias State = TemplatesListFlowState<Content>
    typealias Event = TemplatesListFlowEvent
    typealias Effect = TemplatesListFlowEffect
}

extension TemplatesListFlowReducer {
    
    func reduce(
        _ state: inout State,
        _ event: Event
    ) -> Effect? {
        
        var effect: Effect?
        
        switch event {
        case .dismiss(.destination):
            state.status = nil
            
        case let .payment(payment):
            state.status = .destination(.payment(payment))
            
        case let .select(select):
            switch select {
            case let .productID(productID):
                state.status = .outside(.productID(productID))
                
            case let .template(template):
                state.status = .outside(.inflight)
                effect = .template(template)
            }
        }
        
        return effect
    }
}
