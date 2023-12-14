//
//  CreateSberQRPaymentResponse+DataString.swift
//
//
//  Created by Igor Malyarov on 10.12.2023.
//

public extension CreateSberQRPaymentResponse.Parameter {
    
    struct DataString: Equatable {
        
        public let id: ID
        public let value: String
        
        public init(id: ID, value: String) {
            
            self.id = id
            self.value = value
        }
    }
}
