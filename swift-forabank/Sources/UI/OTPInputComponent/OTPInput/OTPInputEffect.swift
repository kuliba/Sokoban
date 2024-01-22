//
//  OTPInputEffect.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

public enum OTPInputEffect: Equatable {
    
    case countdown(CountdownEffect)
    case otpField(OTPFieldEffect)
}
