//
//  GetSberQRDataResponse+Header.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

public extension GetSberQRDataResponse.Parameter {
    
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

public extension GetSberQRDataResponse.Parameter.Header {
 
    enum ID: String, Equatable {
        
        case title
    }
}
