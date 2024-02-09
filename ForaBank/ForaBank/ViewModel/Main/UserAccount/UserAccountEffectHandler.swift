//
//  UserAccountEffectHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.02.2024.
//

import Foundation
import UserAccountNavigationComponent

final class UserAccountEffectHandler {
    
    private let handleModelEffect: HandleModelEffect
    private let handleOTPEffect: HandleOTPEffect
    
    init(
        handleModelEffect: @escaping HandleModelEffect,
        handleOTPEffect: @escaping HandleOTPEffect
    ) {
        self.handleModelEffect = handleModelEffect
        self.handleOTPEffect = handleOTPEffect
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    
                    dispatch(.dismissInformer)
                }
                
            case let .otp(otpEffect):
                handleOTPEffect(otpEffect) {
                    
                    dispatch(.otp($0))
                }
            }
        }
    }
}

extension UserAccountEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    typealias HandleModelEffect = (Effect.ModelEffect, @escaping Dispatch) -> Void
    
    typealias OTPDispatch = (Event.OTP) -> Void
    typealias HandleOTPEffect = (UserAccountNavigation.Effect.OTP, @escaping OTPDispatch) -> Void
    
    typealias Effect = UserAccountEffect
    typealias Event = UserAccountEvent
}
