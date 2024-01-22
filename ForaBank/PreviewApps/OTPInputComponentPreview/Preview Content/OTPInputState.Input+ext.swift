//
//  OTPInputState.Input+ext.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 22.01.2024.
//

import OTPInputComponent

extension OTPInputState.Input {
 
    static let timerCompleted: Self = .init(
        countdown: .completed,
        otpField: .init()
    )
    static let timerStarting: Self = .init(
        countdown: .starting(duration: 59),
        otpField: .init()
    )
    static let timerRunning: Self = .init(
        countdown: .running(remaining: 23),
        otpField: .init()
    )
    static let incompleteOTP: Self = .init(
        countdown: .running(remaining: 23),
        otpField: .init(text: "2468")
    )
    static let completeOTP: Self = .init(
        countdown: .running(remaining: 23),
        otpField: .init(text: "123456", isInputComplete: true)
    )
}
