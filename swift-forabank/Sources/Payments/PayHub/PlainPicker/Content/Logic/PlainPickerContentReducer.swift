//
//  PlainPickerContentReducer.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public final class PlainPickerContentReducer<Element> {
    
    public init() {}
}

public extension PlainPickerContentReducer {
    
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

public extension PlainPickerContentReducer {
    
    typealias State = PlainPickerContentState<Element>
    typealias Event = PlainPickerContentEvent<Element>
    typealias Effect = PlainPickerContentEffect
}
