//
//  PlainPickerFlowReducer.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public final class PlainPickerFlowReducer<Element, Navigation> {
    
    public init() {}
}

public extension PlainPickerFlowReducer {
    
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

public extension PlainPickerFlowReducer {
    
    typealias State = PlainPickerFlowState<Navigation>
    typealias Event = PlainPickerFlowEvent<Element, Navigation>
    typealias Effect = PlainPickerFlowEffect<Element>
}
