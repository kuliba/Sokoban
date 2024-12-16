//
//  TextInputEffectHandler.swift
//  
//
//  Created by Igor Malyarov on 07.08.2024.
//

public final class TextInputEffectHandler {
    
    public init() {}
}

public extension TextInputEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        }
    }
}

public extension TextInputEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = TextInputEvent
    typealias Effect = TextInputEffect
}
