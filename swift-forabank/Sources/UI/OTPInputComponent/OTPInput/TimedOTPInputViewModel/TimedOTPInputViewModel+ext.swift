//
//  TimedOTPInputViewModel+ext.swift
//
//
//  Created by Igor Malyarov on 15.06.2024.
//

import ForaTools
import Combine
import Foundation

public extension TimedOTPInputViewModel {
    
    convenience init(
        phoneNumber: String? = nil,
        otpText: String = "",
        timerDuration: Int = 60,
        otpLength: Int = 6,
        initiateOTP: @escaping InitiateOTP,
        submitOTP: @escaping SubmitOTP,
        timer: any TimerProtocol = RealTimer(),
        observe: @escaping Observe = { _ in },
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        let countdownReducer = CountdownReducer(duration: timerDuration)
        let otpFieldReducer = OTPFieldReducer(length: otpLength)
        let otpInputReducer = OTPInputReducer(
            countdownReduce: countdownReducer.reduce(_:_:),
            otpFieldReduce: otpFieldReducer.reduce(_:_:)
        )
        
        let countdownEffectHandler = CountdownEffectHandler(initiate: initiateOTP)
        let otpFieldEffectHandler = OTPFieldEffectHandler(submitOTP: submitOTP)
        let otpInputEffectHandler = OTPInputEffectHandler(
            handleCountdownEffect: countdownEffectHandler.handleEffect(_:_:),
            handleOTPFieldEffect: otpFieldEffectHandler.handleEffect(_:_:))

        self.init(
            initialState: .starting(
                phoneNumber: .init(phoneNumber ?? ""),
                duration: timerDuration,
                text: otpText
            ),
            reduce: otpInputReducer.reduce(_:_:),
            handleEffect: otpInputEffectHandler.handleEffect(_:_:),
            timer: timer,
            observe: observe,
            scheduler: scheduler
        )
    }
    
    typealias InitiateOTP = CountdownEffectHandler.InitiateOTP
    typealias SubmitOTP = OTPFieldEffectHandler.SubmitOTP
    
    convenience init(
        initialState: OTPInputState,
        reduce: @escaping Reduce,
        handleEffect: @escaping HandleEffect,
        timer: any TimerProtocol = RealTimer(),
        observe: @escaping Observe = { _ in },
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        let codeObserver = NotificationCenter.default.observe(
            notificationName: "otpCode",
            userInfoKey: "otp"
        )
        
        self.init(
            viewModel: .init(
                initialState: initialState,
                reduce: reduce,
                handleEffect: handleEffect,
                scheduler: scheduler
            ),
            timer: timer,
            observe: observe,
            codeObserver: codeObserver,
            scheduler: scheduler
        )
    }
    
    typealias Effect = OTPInputEffect
    typealias Reduce = (State, Event) -> (State, Effect?)
    typealias HandleEffect = (Effect, @escaping (Event) -> Void) -> Void
}
