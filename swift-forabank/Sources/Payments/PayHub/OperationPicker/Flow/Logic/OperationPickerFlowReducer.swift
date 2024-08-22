//
//  OperationPickerFlowReducer.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public final class OperationPickerFlowReducer<Exchange, Latest, LatestFlow, Status, Templates> {
    
    public init() {}
}

public extension OperationPickerFlowReducer {
    
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

public extension OperationPickerFlowReducer {
    
    typealias State = OperationPickerFlowState<Exchange, LatestFlow, Status, Templates>
    typealias Event = OperationPickerFlowEvent<Exchange, Latest, LatestFlow, Status, Templates>
    typealias Effect = OperationPickerFlowEffect<Latest>
}
