//
//  OTPInputState.Input+ext.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 22.01.2024.
//

extension OTPInputState.Status.Input {
 
    // MARK: - CountdownState
    
    static let timerCompleted: Self = .init(
        countdown: .completed,
        otpField: .init()
    )
    static let timerFailure: Self = .init(
        countdown: .failure(.connectivityError),
        otpField: .init()
    )
    static let timerRunning: Self = .init(
        countdown: .running(remaining: 23),
        otpField: .init()
    )
    static let timerStarting: Self = .init(
        countdown: .starting(duration: 59),
        otpField: .init()
    )
    
    // MARK: - OTPFieldState
    
    static let incompleteOTP: Self = .init(
        countdown: .running(remaining: 23),
        otpField: .init(text: "2468")
    )
    static let completeOTP: Self = .init(
        countdown: .running(remaining: 23),
        otpField: .init(text: "123456", isInputComplete: true)
    )
}
