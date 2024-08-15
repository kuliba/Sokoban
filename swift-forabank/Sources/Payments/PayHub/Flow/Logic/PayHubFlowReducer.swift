//
//  PayHubFlowReducer.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public final class PayHubFlowReducer<Exchange, Latest, LatestFlow, Status, Templates> {
    
    public init() {}
}

public extension PayHubFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .select(select):
            if let select {
                effect = .select(select)
            } else {
                state.selected = .none
            }
            
        case let .flowEvent(flowEvent):
            state.isLoading = flowEvent.isLoading
            state.status = flowEvent.status
            
        case let .selected(selected):
            state.selected = selected
        }
        
        return (state, effect)
    }
}

public extension PayHubFlowReducer {
    
    typealias State = PayHubFlowState<Exchange, LatestFlow, Status, Templates>
    typealias Event = PayHubFlowEvent<Exchange, Latest, LatestFlow, Status, Templates>
    typealias Effect = PayHubFlowEffect<Latest>
}
