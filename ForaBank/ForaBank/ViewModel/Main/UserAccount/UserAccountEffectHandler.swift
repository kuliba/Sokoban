//
//  UserAccountEffectHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.02.2024.
//

import Foundation

final class UserAccountEffectHandler {
    
    private let handleModelEffect: HandleModelEffect
    private let handleOTPEffect: HandleOTPEffect
    private let informerLifespan: TimeInterval
    
    init(
        handleModelEffect: @escaping HandleModelEffect,
        handleOTPEffect: @escaping HandleOTPEffect,
        informerLifespan: TimeInterval = 2
    ) {
        self.handleModelEffect = handleModelEffect
        self.handleOTPEffect = handleOTPEffect
        self.informerLifespan = informerLifespan
    }
}

extension UserAccountEffectHandler {
    
    func handleEffect(
        _ effect: UserAccountEffect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .model(modelEffect):
            handleModelEffect(modelEffect, dispatch)
            
        case let .navigation(navigation):
            switch navigation {
            case .dismissInformer:
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + informerLifespan
                ) {
                    dispatch(.dismiss(.informer))
                }
                
            case let .otp(otpEffect):
                handleOTPEffect(otpEffect) { dispatch(.otp($0)) }
            }
        }
    }
}

extension UserAccountEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    typealias HandleModelEffect = (Effect.ModelEffect, @escaping Dispatch) -> Void
    
    typealias OTPDispatch = (Event.OTPEvent) -> Void
    typealias HandleOTPEffect = (UserAccountEffect.NavigationEffect.OTP, @escaping OTPDispatch) -> Void
    
    typealias Effect = UserAccountEffect
    typealias Event = UserAccountEvent
}
