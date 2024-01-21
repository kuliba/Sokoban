//
//  OTPInputEffectHandler.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

public final class OTPInputEffectHandler {
    
    private let handleCountdownEffect: HandleCountdownEffect
    private let handleOTPFieldEffect: HandleOTPFieldEffect
    
    public init(
        handleCountdownEffect: @escaping HandleCountdownEffect,
        handleOTPFieldEffect: @escaping HandleOTPFieldEffect
    ) {
        self.handleCountdownEffect = handleCountdownEffect
        self.handleOTPFieldEffect = handleOTPFieldEffect
    }
}

public extension OTPInputEffectHandler {
    
    func handleEffect(
        _ effect: OTPInputEffect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .countdown(countdownEffect):
            handleCountdownEffect(countdownEffect, dispatch)
            
        case let .otpField(otpFieldEffect):
            handleOTPFieldEffect(otpFieldEffect, dispatch)
        }
    }
}

public extension OTPInputEffectHandler {
    
    typealias HandleCountdownEffect = (CountdownEffect, @escaping Dispatch) -> Void
    typealias HandleOTPFieldEffect = (OTPFieldEffect, @escaping Dispatch) -> Void
}

public extension OTPInputEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = OTPInputEvent
    typealias Effect = OTPInputEffect
}
