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
    phoneNumber: OTPInputState.PhoneNumberMask = .init(anyMessage()),
    otpField: OTPFieldState = .init()
) -> OTPInputState {
    
    .init(
        phoneNumber: phoneNumber,
        status: .input(.init(
            countdown: .completed,
            otpField: otpField
        ))
    )
}

func running(
    phoneNumber: OTPInputState.PhoneNumberMask = .init(anyMessage()),
    _ remaining: Int,
    otpField: OTPFieldState = .init()
) -> OTPInputState {
    
    .init(
        phoneNumber: phoneNumber,
        status: .input(.init(
            countdown: .running(remaining: remaining),
            otpField: otpField
        ))
    )
}

func starting(
    phoneNumber: OTPInputState.PhoneNumberMask = .init(anyMessage()),
    duration: Int,
    otpField: OTPFieldState = .init()
) -> OTPInputState {
    
    .init(
        phoneNumber: phoneNumber,
        status: .input(.init(
            countdown: .starting(duration: duration),
            otpField: otpField
        ))
    )
}

func completed(
    otpField: OTPFieldState = .init()
) -> OTPInputState.Status {
    
    .input(.init(
        countdown: .completed,
        otpField: otpField
    ))
}

func running(
    _ remaining: Int,
    otpField: OTPFieldState = .init()
) -> OTPInputState.Status {
    
    .input(.init(
        countdown: .running(remaining: remaining),
        otpField: otpField
    ))
}

func starting(
    _ duration: Int,
    otpField: OTPFieldState = .init()
) -> OTPInputState.Status {
    
    .input(.init(
        countdown: .starting(duration: duration),
        otpField: otpField
    ))
}

func runningInflight(
    phoneNumber: OTPInputState.PhoneNumberMask = .init(anyMessage()),
    _ remaining: Int,
    _ text: String
) -> OTPInputState.Status {
    
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
