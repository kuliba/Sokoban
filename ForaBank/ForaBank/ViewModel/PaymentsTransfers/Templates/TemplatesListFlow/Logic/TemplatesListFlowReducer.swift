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

private extension TemplatesListFlowReducer {
    
    func reduce(
        _ state: inout State,
        _ event: Event
    ) -> Effect? {
        
        var effect: Effect?
        
        switch event {
        case .dismiss(.destination):
            state.status = nil
            
        case let .flow(flow):
            reduce(&state, &effect, with: flow)

        case let .payment(result):
            reduce(&state, &effect, with: result)
            
        case let .select(select):
            reduce(&state, &effect, with: select)
        }
        
        return effect
    }
    
    private func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with flow: Event.FlowEvent
    ) {
        switch flow {
        case .tab(.payments):
            state.status = .outside(.tab(.payments))
        }
    }
    
    private func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with result: Event.PaymentResult
    ) {
        switch result {
        case let .failure(serviceFailure):
            state.status = .alert(serviceFailure)
            
        case let .success(.legacy(legacy)):
            state.status = .destination(.payment(.legacy(legacy)))
            
        case let .success(.v1(node)):
            state.status = .destination(.payment(.v1(node)))
        }
    }
    
    private func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with select: Event.Select
    ) {
        switch select {
        case let .productID(productID):
            state.status = .outside(.productID(productID))
            
        case let .template(template):
            state.status = .outside(.inflight)
            effect = .template(template)
        }
    }
}
