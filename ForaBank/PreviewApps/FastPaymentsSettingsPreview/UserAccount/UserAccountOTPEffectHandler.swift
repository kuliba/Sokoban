//
//  UserAccountOTPEffectHandler.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 28.01.2024.
//

import FastPaymentsSettings
import UserAccountNavigationComponent

final class UserAccountOTPEffectHandler {
    
    private let prepareSetBankDefault: PrepareSetBankDefault
    
    init(
        prepareSetBankDefault: @escaping PrepareSetBankDefault
    ) {
        self.prepareSetBankDefault = prepareSetBankDefault
    }
}

extension UserAccountOTPEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        dispatch: @escaping (Event) -> Void
    ) {
        switch effect {
        case .prepareSetBankDefault:
            prepareSetBankDefault { result in
                
                switch result {
                case .success(()):
                    dispatch(.prepareSetBankDefaultResponse(.success))
                    
                case .failure(.connectivityError):
                    dispatch(.prepareSetBankDefaultResponse(.connectivityError))
                    
                case let .failure(.serverError(message)):
                    dispatch(.prepareSetBankDefaultResponse(.serverError(message)))
                }
            }
        }
    }
}

extension UserAccountOTPEffectHandler {
    
    typealias PrepareSetBankDefault = FastPaymentsSettingsEffectHandler.PrepareSetBankDefault

    typealias Effect = UserAccountNavigation.Effect.OTP
    typealias Event = UserAccountNavigation.Event.OTP
}
