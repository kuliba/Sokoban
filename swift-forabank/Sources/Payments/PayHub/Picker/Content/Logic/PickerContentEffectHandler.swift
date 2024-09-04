//
//  PickerContentEffectHandler.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public final class PickerContentEffectHandler<Element> {
    
    public init() {}
}

public extension PickerContentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        }
    }
}

public extension PickerContentEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PickerContentEvent<Element>
    typealias Effect = PickerContentEffect
}
