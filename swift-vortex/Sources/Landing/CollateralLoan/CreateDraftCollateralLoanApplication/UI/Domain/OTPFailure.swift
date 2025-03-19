//
//  OTPFailure.swift
//  swift-vortex
//
//  Created by Valentin Ozerov on 18.03.2025.
//

public enum OTPFailure: Error, Equatable {
    
    case connectivityError
    case serverError(String)
}
