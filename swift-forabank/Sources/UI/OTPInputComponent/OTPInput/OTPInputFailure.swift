//
//  OTPInputFailure.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

public enum OTPInputFailure: Error, Equatable {
    
    case connectivityError
    case serverError(String)
}
