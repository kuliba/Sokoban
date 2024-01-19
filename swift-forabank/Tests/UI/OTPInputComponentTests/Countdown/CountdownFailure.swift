//
//  CountdownFailure.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

enum CountdownFailure: Error, Equatable {
    
    case connectivityError
    case serverError(String)
}
