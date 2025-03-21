//
//  Effect.swift
//  
//
//  Created by Igor Malyarov on 21.03.2025.
//

public enum Effect<ApplicationPayload, OTP> {
    
    case apply(ApplicationPayload)
    case loadOTP
    case notifyOTP(OTP, String)
}

extension Effect: Equatable where OTP: Equatable, ApplicationPayload: Equatable {}

