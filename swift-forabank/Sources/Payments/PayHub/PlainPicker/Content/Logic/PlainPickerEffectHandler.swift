//
//  PlainPickerEffectHandler.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public final class PlainPickerEffectHandler<Element> {
    
    public init() {}
}

public extension PlainPickerEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        }
    }
}

public extension PlainPickerEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PlainPickerEvent<Element>
    typealias Effect = PlainPickerEffect
}
