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
