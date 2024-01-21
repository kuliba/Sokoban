//
//  OTPInputState.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

public struct OTPInputState: Equatable {
    
    public var countdown: CountdownState
    public var otpField: OTPFieldState
    
    public init(
        countdown: CountdownState,
        otpField: OTPFieldState
    ) {
        self.countdown = countdown
        self.otpField = otpField
    }
}
