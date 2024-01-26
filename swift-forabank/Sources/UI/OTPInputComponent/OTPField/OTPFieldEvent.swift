//
//  OTPFieldEvent.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

public enum OTPFieldEvent: Equatable {
    
    case confirmOTP
    case edit(String)
    case failure(ServiceFailure)
    case otpValidated
}
