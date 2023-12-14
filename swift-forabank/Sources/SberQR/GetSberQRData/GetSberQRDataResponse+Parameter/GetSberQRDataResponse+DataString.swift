//
//  GetSberQRDataResponse+DataString.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

public extension GetSberQRDataResponse.Parameter {
    
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

public extension GetSberQRDataResponse.Parameter.DataString {
    
    enum ID: String, Equatable {
        
        case currency
    }
}
