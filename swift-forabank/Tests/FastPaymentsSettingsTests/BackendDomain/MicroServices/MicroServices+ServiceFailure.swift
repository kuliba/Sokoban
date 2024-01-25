//
//  MicroServices+ServiceFailure.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

public extension MicroServices {
    
    enum ServiceFailure: Error, Equatable {
        
        case connectivityError
        case serviceError(String)
    }
}
