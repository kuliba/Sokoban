//
//  OTPInputViewModel+default.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import ForaTools

public extension OTPInputState {
    
    static func starting(
        phoneNumber: PhoneNumberMask,
        duration: Int
    ) -> Self {
        
        .init(
            phoneNumber: phoneNumber,
            status: .input(.init(
                countdown: .starting(duration: duration),
                otpField: .init()
            ))
        )
    }
}

public extension OTPInputViewModel {
    
    static func `default`(
        initialState: OTPInputState,
        timer: TimerProtocol = RealTimer(),
        duration: Int = 60,
        length: Int = 6,
        initiateOTP: @escaping CountdownEffectHandler.InitiateOTP,
        submitOTP: @escaping OTPFieldEffectHandler.SubmitOTP,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> OTPInputViewModel {
                
        let countdownReducer = CountdownReducer(duration: duration)
        let otpFieldReducer = OTPFieldReducer(length: length)
        let otpInputReducer = OTPInputReducer(
            countdownReduce: countdownReducer.reduce(_:_:),
            otpFieldReduce: otpFieldReducer.reduce(_:_:)
        )
        
        let countdownEffectHandler = CountdownEffectHandler(initiate: initiateOTP)
        let otpFieldEffectHandler = OTPFieldEffectHandler(submitOTP: submitOTP)
        let otpInputEffectHandler = OTPInputEffectHandler(
            handleCountdownEffect: countdownEffectHandler.handleEffect(_:_:),
            handleOTPFieldEffect: otpFieldEffectHandler.handleEffect(_:_:))
        
        return .init(
            initialState: initialState,
            reduce: otpInputReducer.reduce(_:_:),
            handleEffect: otpInputEffectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}
