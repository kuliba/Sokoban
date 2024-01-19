//
//  OTPInputEffectHandler.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

public final class OTPInputEffectHandler {
    
    public init() {}
}

public extension OTPInputEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        fatalError()
    }
}

public extension OTPInputEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = OTPInputState
    typealias Event = OTPInputEvent
    typealias Effect = OTPInputEffect
}
