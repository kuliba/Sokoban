//
//  OTPFieldHelpers.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import OTPInputComponent

func connectivity(
) -> OTPFieldState {
    
    .init(status: .failure(.connectivityError))
}

func server(
    _ message: String = anyMessage()
) -> OTPFieldState {
    
    .init(status: .failure(.serverError(message)))
}

func validOTP(
) -> OTPFieldState {
    
    .init(status: .validOTP)
}
