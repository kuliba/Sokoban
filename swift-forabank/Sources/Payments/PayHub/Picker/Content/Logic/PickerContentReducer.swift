//
//  PickerContentReducer.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public final class PickerContentReducer<Element> {
    
    public init() {}
}

public extension PickerContentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .select(element):
            state.selection = element
        }
        
        return (state, effect)
    }
}

public extension PickerContentReducer {
    
    typealias State = PickerContentState<Element>
    typealias Event = PickerContentEvent<Element>
    typealias Effect = PickerContentEffect
}
