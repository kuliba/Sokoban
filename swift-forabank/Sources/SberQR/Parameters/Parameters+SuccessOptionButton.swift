//
//  Parameters+SuccessOptionButtons.swift
//  
//
//  Created by Igor Malyarov on 16.12.2023.
//

public extension Parameters {
    
    struct SuccessOptionButtons: Equatable {
        
        public typealias ID = CreateSberQRPaymentIDs.SuccessOptionButtonsID
        
        let id: ID
        public let values: [Value]
        
        public init(id: ID, values: [Value]) {
            
            self.id = id
            self.values = values
        }
        
        public enum Value: Equatable {
            
            case details, document
        }
    }
}
