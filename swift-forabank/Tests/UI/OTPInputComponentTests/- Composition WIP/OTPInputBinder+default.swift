//
//  OTPInputBinder+default.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import OTPInputComponent

extension OTPInputState {
    
    static let starting: Self = .init(
        countdown: .starting,
        otpField: .init()
    )
}

extension OTPInputBinder {
    
#warning("improve duration with Tagged")
    static func `default`(
        initialOTPInputState: OTPInputState = .starting,
        timer: TimerProtocol = RealTimer(),
        duration: Int = 60,
        initiate: @escaping CountdownEffectHandler.Initiate,
        submitOTP: @escaping OTPFieldEffectHandler.SubmitOTP,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> OTPInputBinder {
        
        let countdownReducer = CountdownReducer(duration: duration)
        let otpFieldReducer = OTPFieldReducer()
        let otpInputReducer = OTPInputReducer(
            countdownReduce: countdownReducer.reduce(_:_:),
            otpFieldReduce: otpFieldReducer.reduce(_:_:)
        )
        
        let countdownEffectHandler = CountdownEffectHandler(initiate: initiate)
        let otpFieldEffectHandler = OTPFieldEffectHandler(submitOTP: submitOTP)
        
        let otpInputEffectHandler = OTPInputEffectHandler(
            handleCountdownEffect: countdownEffectHandler.handleEffect(_:_:),
            handleOTPFieldEffect: otpFieldEffectHandler.handleEffect(_:_:))
        
        let otpInputViewModel = OTPInputViewModel(
            initialState: initialOTPInputState,
            reducer: otpInputReducer,
            effectHandler: otpInputEffectHandler,
            scheduler: scheduler
        )
        
        return .init(
            timer: timer,
            duration: duration,
            otpInputViewModel: otpInputViewModel,
            scheduler: scheduler
        )
    }
}
