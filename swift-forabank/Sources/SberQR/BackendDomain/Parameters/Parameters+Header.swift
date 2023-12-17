//
//  Parameters+Header.swift
//
//
//  Created by Igor Malyarov on 16.12.2023.
//

public extension Parameters {
    
    struct Header<ID> {
        
        let id: ID
        public let value: String
        
        public init(
            id: ID,
            value: String
        ) {
            self.id = id
            self.value = value
        }
    }
}

extension Parameters.Header: Equatable where ID: Equatable {}
