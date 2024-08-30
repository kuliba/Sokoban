//
//  PlainPickerReducer.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public final class PlainPickerReducer<Element> {
    
    public init() {}
}

public extension PlainPickerReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
            
        }
        
        return (state, effect)
    }
}

public extension PlainPickerReducer {
    
    typealias State = PlainPickerState<Element>
    typealias Event = PlainPickerEvent<Element>
    typealias Effect = PlainPickerEffect
}
