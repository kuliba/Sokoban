//
//  PickerFlowReducer.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public final class PickerFlowReducer<Element, Navigation> {
    
    public init() {}
}

public extension PickerFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?

        state.isLoading = false
        
        switch event {
        case .dismiss:
            state.navigation = nil
            
        case let .navigation(navigation):
            state.navigation = navigation
            
        case let .select(element):
            state.isLoading = true
            effect = .select(element)
        }
        
        return (state, effect)
    }
}

public extension PickerFlowReducer {
    
    typealias State = PickerFlowState<Navigation>
    typealias Event = PickerFlowEvent<Element, Navigation>
    typealias Effect = PickerFlowEffect<Element>
}
