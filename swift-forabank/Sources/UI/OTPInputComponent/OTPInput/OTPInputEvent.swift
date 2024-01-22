//
//  OTPInputEvent.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

public enum OTPInputEvent: Equatable {
    
    case countdown(CountdownEvent)
    case otpField(OTPFieldEvent)
}
