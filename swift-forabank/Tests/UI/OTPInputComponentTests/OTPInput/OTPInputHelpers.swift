//
//  OTPInput.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import OTPInputComponent

func submitOTP(
    _ otp: String = anyMessage()
) -> OTPInputEffect {
    
    .otpField(.submitOTP(otp))
}

func completed(
    otpField: OTPFieldState = .init()
) -> OTPInputState {
    
    .input(.init(
        countdown: .completed,
        otpField: otpField
    ))
}

func running(
    _ remaining: Int,
    otpField: OTPFieldState = .init()
) -> OTPInputState {
    
    .input(.init(
        countdown: .running(remaining: remaining),
        otpField: otpField
    ))
}

func runningInflight(
    _ remaining: Int,
    _ text: String
) -> OTPInputState {
    
    .input(.init(
        countdown: .running(remaining: remaining),
        otpField: .init(
            text: text,
            isInputComplete: true,
            status: .inflight
        )
    ))
}

func text(
    _ text: String
) -> OTPFieldState {
    
    .init(text: text)
}

func completed(
    _ text: String
) -> OTPFieldState {
    
    .init(text: text, isInputComplete: true)
}

func inflight(
    _ text: String
) -> OTPFieldState {
    
    .init(text: text, isInputComplete: true, status: .inflight)
}

func validOTP(
    _ text: String
) -> OTPFieldState {
    
    .init(text: text, isInputComplete: true, status: .validOTP)
}

func prepare(
) -> OTPInputEvent {
    
    .countdown(.prepare)
}
