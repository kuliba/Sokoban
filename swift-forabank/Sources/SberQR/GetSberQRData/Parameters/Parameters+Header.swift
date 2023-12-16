//
//  Parameters+Header.swift
//
//
//  Created by Igor Malyarov on 16.12.2023.
//

public extension Parameters {
    
    struct Header: Equatable {
        
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

public extension Parameters.Header {
 
    enum ID: String, Equatable {
        
        case title
    }
}
