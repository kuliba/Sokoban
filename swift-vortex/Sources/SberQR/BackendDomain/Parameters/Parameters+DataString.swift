//
//  Parameters+DataString.swift
//
//
//  Created by Igor Malyarov on 16.12.2023.
//

public extension Parameters {
    
    struct DataString<ID> {
        
        public let id: ID
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

extension Parameters.DataString: Equatable where ID: Equatable {}
