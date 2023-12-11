//
//  CreateSberQRPaymentResponse+SuccessStatusIcon.swift
//
//
//  Created by Igor Malyarov on 10.12.2023.
//

public extension CreateSberQRPaymentResponse.Parameter {
    
    struct SuccessStatusIcon: Equatable {
        
        let id: ID
        let value: StatusIcon
        
        public init(id: ID, value: StatusIcon) {
            
            self.id = id
            self.value = value
        }
        
        public enum StatusIcon: Equatable {
            
            case complete
            case inProgress
            case rejected
        }
    }
}
