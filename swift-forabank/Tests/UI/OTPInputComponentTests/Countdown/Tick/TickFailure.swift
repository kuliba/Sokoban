//
//  TickFailure.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

enum TickFailure: Error, Equatable {
    
    case connectivityError
    case serverError(String)
}
