//
//  ServiceFailure.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

struct ServiceFailure: Error, Equatable {
    
    let message: String
    let source: Source
}

extension ServiceFailure {
    
    enum Source: Equatable {
        
        case connectivity, server
    }
}
