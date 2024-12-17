//
//  CountdownHelpers.swift
//
//
//  Created by Igor Malyarov on 21.01.2024.
//

import OTPInputComponent

func running(
    _ remaining: Int
) -> CountdownState {
    
    .running(remaining: remaining)
}

func connectivityError(
) -> CountdownState {
    
    .failure(.connectivityError)
}

func serverError(
    _ message: String = anyMessage()
) -> CountdownState {
    
    .failure(.serverError(message))
}
