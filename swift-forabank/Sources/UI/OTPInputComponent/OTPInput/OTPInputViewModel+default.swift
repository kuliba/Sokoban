//
//  OTPInputViewModel+default.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

public extension OTPInputState {
    
    static let starting: Self = .input(.init(
        countdown: .starting,
        otpField: .init()
    ))
}

public extension OTPInputViewModel {
    
#warning("improve duration with Tagged")
    static func `default`(
        initialOTPInputState: OTPInputState = .starting,
        timer: TimerProtocol = RealTimer(),
        duration: Int = 60,
        length: Int = 6,
        initiate: @escaping CountdownEffectHandler.Initiate,
        submitOTP: @escaping OTPFieldEffectHandler.SubmitOTP,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> OTPInputViewModel {
        
        let countdownReducer = CountdownReducer(duration: duration)
        let otpFieldReducer = OTPFieldReducer(length: length)
        let otpInputReducer = OTPInputReducer(
            countdownReduce: countdownReducer.reduce(_:_:),
            otpFieldReduce: otpFieldReducer.reduce(_:_:)
        )
        
        let countdownEffectHandler = CountdownEffectHandler(initiate: initiate)
        let otpFieldEffectHandler = OTPFieldEffectHandler(submitOTP: submitOTP)
        
        let otpInputEffectHandler = OTPInputEffectHandler(
            handleCountdownEffect: countdownEffectHandler.handleEffect(_:_:),
            handleOTPFieldEffect: otpFieldEffectHandler.handleEffect(_:_:))
        
        return .init(
            initialState: initialOTPInputState,
            reduce: otpInputReducer.reduce(_:_:),
            handleEffect: otpInputEffectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}
