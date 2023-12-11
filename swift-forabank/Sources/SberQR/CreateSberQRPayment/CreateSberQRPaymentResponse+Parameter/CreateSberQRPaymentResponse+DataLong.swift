//
//  CreateSberQRPaymentResponse+DataLong.swift
//
//
//  Created by Igor Malyarov on 10.12.2023.
//

public extension CreateSberQRPaymentResponse.Parameter {
    
    struct DataLong: Equatable {
        
        public let id: ID
        public let value: Int
        
        public init(id: ID, value: Int) {

            self.id = id
            self.value = value
        }
    }
}
