//
//  DataString.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

extension GetSberQRDataResponse.Parameter {

    struct DataString: Equatable {
        
        typealias ID = String
        
        let id: ID
        let value: String
    }
}
