//
//  ServiceFailure.swift
//  
//
//  Created by Igor Malyarov on 09.03.2024.
//

public enum ServiceFailure: Error, Equatable {
    
    case connectivityError
    case serverError(String)
}
