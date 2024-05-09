//
//  ServiceFailure.swift
//
//
//  Created by Igor Malyarov on 09.03.2024.
//

struct ServiceFailureAlert: Equatable {
    
    let serviceFailure: ServiceFailure
    
    enum ServiceFailure: Error, Hashable {
        
        case connectivityError
        case serverError(String)
    }
}
