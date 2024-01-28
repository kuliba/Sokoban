//
//  UserAccountNavigationOTPEffectHandler.swift
//
//
//  Created by Igor Malyarov on 28.01.2024.
//

import FastPaymentsSettings

public final class UserAccountNavigationOTPEffectHandler {
    
    private let prepareSetBankDefault: PrepareSetBankDefault
    
    public init(
        prepareSetBankDefault: @escaping PrepareSetBankDefault
    ) {
        self.prepareSetBankDefault = prepareSetBankDefault
    }
}

public extension UserAccountNavigationOTPEffectHandler {
    
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

public extension UserAccountNavigationOTPEffectHandler {
    
    typealias PrepareSetBankDefault = FastPaymentsSettingsEffectHandler.PrepareSetBankDefault

    typealias Effect = UserAccountNavigation.Effect.OTP
    typealias Event = UserAccountNavigation.Event.OTP
}
