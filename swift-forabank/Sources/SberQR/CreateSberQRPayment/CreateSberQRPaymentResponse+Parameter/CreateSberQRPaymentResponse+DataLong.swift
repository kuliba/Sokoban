//
//  CreateSberQRPaymentResponse+DataLong.swift
//
//
//  Created by Igor Malyarov on 10.12.2023.
//

public extension CreateSberQRPaymentResponse.Parameter {
    
    #warning("move to Parameters, replace with typealias")
    struct DataLong: Equatable {
        
        public let id: CreateSberQRPaymentIDs.ID
        public let value: Int
        
        public init(id: CreateSberQRPaymentIDs.ID, value: Int) {
            
            self.id = id
            self.value = value
        }
    }
}
