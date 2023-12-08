//
//  DataString.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

extension GetSberQRDataResponse.Parameter {

    struct DataString: Equatable {
        
        let id: ID
        let value: String
        
        enum ID: String, Equatable {
            
            case currency
        }
    }
}
