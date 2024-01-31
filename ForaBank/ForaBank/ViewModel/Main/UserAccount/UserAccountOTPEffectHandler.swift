//
//  UserAccountOTPEffectHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 31.01.2024.
//

final class UserAccountOTPEffectHandler {
    
}

extension UserAccountOTPEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        fatalError()
    }
}

extension UserAccountOTPEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UserAccountEvent.OTP
    typealias Effect = UserAccountEffect.OTP
}
