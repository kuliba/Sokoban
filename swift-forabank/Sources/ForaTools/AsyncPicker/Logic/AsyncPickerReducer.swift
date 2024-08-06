//
//  AsyncPickerReducer.swift
//
//
//  Created by Igor Malyarov on 23.07.2024.
//

/// A reducer that handles state transitions and effects for the asynchronous picker.
public final class AsyncPickerReducer<Payload, Item, Response> {
    
    /// Initialises a new instance of `AsyncPickerReducer`.
    public init() {}
}

public extension AsyncPickerReducer {
    
    /// Reduces the given state and event to produce a new state and an optional effect.
    /// - Parameters:
    ///   - state: The current state of the picker.
    ///   - event: The event to handle.
    /// - Returns: A tuple containing the new state and an optional effect.
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        let effect = reduce(&state, event)
        
        return (state, effect)
    }
}

public extension AsyncPickerReducer {
    
    /// The state type associated with the reducer.
    typealias State = AsyncPickerState<Payload, Item, Response>
    
    /// The event type associated with the reducer.
    typealias Event = AsyncPickerEvent<Item, Response>
    
    /// The effect type associated with the reducer.
    typealias Effect = AsyncPickerEffect<Payload, Item>
}

extension AsyncPickerReducer {
    
    /// Handles the given event to produce a new state and an optional effect.
    /// - Parameters:
    ///   - state: The current state of the picker.
    ///   - event: The event to handle.
    /// - Returns: An optional effect that resulted from handling the event.
    func reduce(
        _ state: inout State,
        _ event: Event
    ) -> Effect? {
        
        var effect: Effect?
        
        switch event {
        case .load:
            guard !state.isLoading else { break }
            
            state.isLoading = true
            effect = .load(state.payload)
            
        case let .loaded(items):
            guard state.isLoading else { break }
            
            state.isLoading = false
            state.items = items
            
        case .reset:
            state.response = nil
            
        case let .response(response):
            state.isLoading = false
            state.response = response
            
        case let .select(item):
            guard let items = state.items,
                  !items.isEmpty
            else { break }
            
            state.isLoading = true
            effect = .select(item, state.payload)
        }
        
        return effect
    }
}
