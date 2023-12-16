//
//  Parameters+DataLong.swift
//  
//
//  Created by Igor Malyarov on 16.12.2023.
//

public extension Parameters {
    
    struct DataLong: Equatable {
        
        public let id: CreateSberQRPaymentIDs.ID
        public let value: Int
        
        public init(id: CreateSberQRPaymentIDs.ID, value: Int) {
            
            self.id = id
            self.value = value
        }
    }
}
