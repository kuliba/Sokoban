//
//  OTPInputEffectHandler.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

public final class OTPInputEffectHandler {
    
    private let submitOTP: SubmitOTP
    
    public init(submitOTP: @escaping SubmitOTP) {
        
        self.submitOTP = submitOTP
    }
}

public extension OTPInputEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .submitOTP(otp):
            submitOTP(otp) { [weak self] result in
                
                self?.submitOTP(result, dispatch)
            }
        }
    }
}

public extension OTPInputEffectHandler {
    
    #warning("replace with strong Tagged type")
    typealias SubmitOTPPayload = String
    typealias SubmitOTPResult = Result<Void, OTPInputFailure>
    typealias SubmitOTPCompletion = (SubmitOTPResult) -> Void
    typealias SubmitOTP = (SubmitOTPPayload, @escaping SubmitOTPCompletion) -> Void
}

public extension OTPInputEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = OTPInputState
    typealias Event = OTPInputEvent
    typealias Effect = OTPInputEffect
}

private extension OTPInputEffectHandler {
    
    func submitOTP(
        _ result: OTPInputEffectHandler.SubmitOTPResult,
        _ dispatch: @escaping Dispatch
    ) {
        switch result {
        case let .failure(otpInputFailure):
            dispatch(.failure(otpInputFailure))
            
        case .success(()):
            dispatch(.otpValidated)
        }
    }
}
