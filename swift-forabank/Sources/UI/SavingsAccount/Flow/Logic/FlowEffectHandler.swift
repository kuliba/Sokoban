//
//  FlowEffectHandler.swift
//
//
//  Created by Andryusina Nataly on 04.12.2024.
//

public final class FlowEffectHandler<Destination, InformerPayload> {
        
    public init() {}
}

public extension FlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        }
    }
}

public extension FlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = FlowEvent<Destination, InformerPayload>
    typealias Effect = FlowEffect
}
