//
//  CreateSberQRPaymentResponse+SuccessOptionButton.swift
//
//
//  Created by Igor Malyarov on 10.12.2023.
//

public extension CreateSberQRPaymentResponse.Parameter {
    
#warning("move to Parameters, replace with typealias")
    struct SuccessOptionButton: Equatable {
        
        let id: CreateSberQRPaymentIDs.ID
        public let values: [Value]
        
        public init(id: CreateSberQRPaymentIDs.ID, values: [Value]) {
            
            self.id = id
            self.values = values
        }
        
        public enum Value: Equatable {
            
            case details, document
        }
    }
}
