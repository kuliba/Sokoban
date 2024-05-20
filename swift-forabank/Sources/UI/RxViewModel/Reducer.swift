//
//  Reducer.swift
//
//
//  Created by Igor Malyarov on 20.01.2024.
//

public protocol Reducer<State, Event, Effect> {
    
    associatedtype State
    associatedtype Event
    associatedtype Effect
    
    func reduce(_ state: State,_ event: Event) -> (State, Effect?)
}

public extension Reducer {
    
    func reduce(
        _ state: inout State,
        _ event: Event
    ) -> Effect? {
        
        let (newState, effect) = reduce(state, event)
        state = newState
        
        return effect
    }
}
