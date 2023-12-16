//
//  Parameters+DataString.swift
//
//
//  Created by Igor Malyarov on 16.12.2023.
//

public extension Parameters {
    
    struct DataString: Equatable {
        
        let id: ID
        let value: String
        
        public init(
            id: ID,
            value: String
        ) {
            self.id = id
            self.value = value
        }
    }
}

public extension Parameters.DataString {
    
    enum ID: String, Equatable {
        
        case currency
    }
}
