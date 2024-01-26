//
//  OTPFieldEffectHandler.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

import Tagged

public final class OTPFieldEffectHandler {
    
    private let submitOTP: SubmitOTP
    
    public init(submitOTP: @escaping SubmitOTP) {
        
        self.submitOTP = submitOTP
    }
}

public extension OTPFieldEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .submitOTP(otp):
            submitOTP(.init(otp)) { [weak self] result in
                
                self?.submitOTP(result, dispatch)
            }
        }
    }
}

public extension OTPFieldEffectHandler {
    
    typealias SubmitOTPPayload = OTP
    typealias SubmitOTPResult = Result<Void, ServiceFailure>
    typealias SubmitOTPCompletion = (SubmitOTPResult) -> Void
    typealias SubmitOTP = (SubmitOTPPayload, @escaping SubmitOTPCompletion) -> Void
    
    typealias OTP = Tagged<_OTP, String>
    enum _OTP {}
}

public extension OTPFieldEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = OTPFieldState
    typealias Event = OTPFieldEvent
    typealias Effect = OTPFieldEffect
}

private extension OTPFieldEffectHandler {
    
    func submitOTP(
        _ result: OTPFieldEffectHandler.SubmitOTPResult,
        _ dispatch: @escaping Dispatch
    ) {
        switch result {
        case let .failure(OTPFieldFailure):
            dispatch(.failure(OTPFieldFailure))
            
        case .success(()):
            dispatch(.otpValidated)
        }
    }
}
