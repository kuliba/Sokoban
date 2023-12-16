//
//  Parameters+SuccessStatusIcon.swift
//  
//
//  Created by Igor Malyarov on 16.12.2023.
//

public extension Parameters {
    
    struct SuccessStatusIcon: Equatable {
        
        let id: CreateSberQRPaymentIDs.ID
        public let value: StatusIcon
        
        public init(id: CreateSberQRPaymentIDs.ID, value: StatusIcon) {
            
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
