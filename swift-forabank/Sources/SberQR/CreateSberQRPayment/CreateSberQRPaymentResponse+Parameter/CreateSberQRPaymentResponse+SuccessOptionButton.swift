//
//  CreateSberQRPaymentResponse+SuccessOptionButton.swift
//
//
//  Created by Igor Malyarov on 10.12.2023.
//

public extension CreateSberQRPaymentResponse.Parameter {
    
    struct SuccessOptionButton: Equatable {
        
        let id: ID
        let values: [Value]
        
        public init(id: ID, values: [Value]) {
            
            self.id = id
            self.values = values
        }
        
        public enum Value: Equatable {
            
            case details, document
        }
    }
}
