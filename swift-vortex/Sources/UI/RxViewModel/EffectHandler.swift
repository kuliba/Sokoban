//
//  EffectHandler.swift
//  
//
//  Created by Igor Malyarov on 20.01.2024.
//

public protocol EffectHandler<Event, Effect> {
    
    associatedtype Event
    associatedtype Effect
    
    typealias Dispatch = (Event) -> Void
    
    func handleEffect(
        _ effect: Effect, 
        _ dispatch: @escaping Dispatch
    ) -> Void
}
