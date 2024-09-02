//
//  ServiceFailure.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

public struct ServiceFailure: Error, Equatable {
    
    public let message: String
    public let source: Source
    
    public init(
        message: String,
        source: Source
    ) {
        self.message = message
        self.source = source
    }
}

public extension ServiceFailure {
    
    enum Source: Equatable {
        
        case connectivity, server
    }
}

public extension ServiceFailure {
    
    static func connectivity(
        _ message: String
    ) -> Self {
        
        return .init(message: message, source: .connectivity)
    }
    
    static func server(
        _ message: String
    ) -> Self {
        
        return .init(message: message, source: .server)
    }
}
