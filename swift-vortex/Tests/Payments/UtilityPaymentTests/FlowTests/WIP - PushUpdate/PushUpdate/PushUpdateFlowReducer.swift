//
//  PushUpdateFlowReducer.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

import UtilityPayment

public final class PushUpdateFlowReducer<Destination, PushEvent, UpdateEvent, PushEffect, UpdateEffect> {
    
    private let push: Push
    private let update: Update
    
    public init(
        push: @escaping Push,
        update: @escaping Update
    ) {
        self.push = push
        self.update = update
    }
}

public extension PushUpdateFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .push(pushEvent):
            let (destination, pushEffect) = push(state, pushEvent)
            state.push(destination)
            effect = pushEffect.map { .push($0) }
            
        case let .update(updateEvent):
            let (destination, updateEffect) = update(state, updateEvent)
            state.current = destination
            effect = updateEffect.map { .update($0) }
        }
        
        return (state, effect)
    }
}

public extension PushUpdateFlowReducer {
    
    typealias Push = (State, PushEvent) -> (Destination, PushEffect?)
    #warning("add test for nil destination!! with empty and non-empty stack!!")
    typealias Update = (State, UpdateEvent) -> (Destination?, UpdateEffect?)
    
    typealias State = Flow<Destination>
    typealias Event = PushUpdateFlowEvent<PushEvent, UpdateEvent>
    typealias Effect = PushUpdateFlowEffect<PushEffect, UpdateEffect>
}
