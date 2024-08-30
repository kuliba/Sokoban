//
//  PlainPickerContentEffectHandler.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public final class PlainPickerContentEffectHandler<Element> {
    
    public init() {}
}

public extension PlainPickerContentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        }
    }
}

public extension PlainPickerContentEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PlainPickerContentEvent<Element>
    typealias Effect = PlainPickerContentEffect
}
