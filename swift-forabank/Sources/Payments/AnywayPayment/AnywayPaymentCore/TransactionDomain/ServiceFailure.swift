//
//  ServiceFailure.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

public enum ServiceFailure: Error, Equatable {
    
    case connectivityError
    case serverError(String)
}
