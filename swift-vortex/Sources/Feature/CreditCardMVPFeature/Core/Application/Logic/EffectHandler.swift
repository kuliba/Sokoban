//
//  EffectHandler.swift
//
//
//  Created by Igor Malyarov on 21.03.2025.
//

/// A type that provides a verification code (e.g., OTP).
public protocol VerificationCodeProviding {
    
    /// The verification code as a string (e.g., OTP).
    var verificationCode: String { get }
}

public final class EffectHandler<ApplicationPayload, ApplicationSuccess, OTP>
where ApplicationPayload: VerificationCodeProviding {
    
    private let apply: Apply
    private let loadOTP: LoadOTP
    private let otpWitness: OTPWitness
    
    public init(
        apply: @escaping Apply,
        loadOTP: @escaping LoadOTP,
        otpWitness: @escaping OTPWitness
    ) {
        self.apply = apply
        self.loadOTP = loadOTP
        self.otpWitness = otpWitness
    }
    
    public typealias ApplyCompletion = (Event.ApplicationResult) -> Void
    public typealias Apply = (ApplicationPayload, @escaping ApplyCompletion) -> Void
    
    public typealias LoadOTPCompletion = (Event.LoadedOTPResult) -> Void
    public typealias LoadOTP = (@escaping LoadOTPCompletion) -> Void
    
    public typealias OTPWitness = (OTP) -> (String) -> Void
}

public extension EffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .apply(payload):
            apply(payload) { dispatch(.applicationResult($0)) }
            
        case .loadOTP:
            loadOTP { dispatch(.loadedOTP($0)) }
            
        case let .notifyOTP(otp, message):
            otpWitness(otp)(message)
        }
    }
}

public extension EffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = CreditCardMVPCore.Event<ApplicationSuccess>
    typealias Effect = CreditCardMVPCore.Effect<ApplicationPayload, OTP>
}
