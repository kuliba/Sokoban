//
//  Parameters+SuccessStatusIcon.swift
//
//
//  Created by Igor Malyarov on 16.12.2023.
//

public extension Parameters {
    
    struct SuccessStatusIcon: Equatable {
        
        public typealias ID = CreateSberQRPaymentIDs.SuccessStatusID
        
        let id: ID
        public let value: StatusIcon
        
        public init(id: ID, value: StatusIcon) {
            
            self.id = id
            self.value = value
        }
    }
}

public extension Parameters.SuccessStatusIcon {
    
    enum StatusIcon: Equatable {
        
        case complete
        case inProgress
        case rejected
        case suspended
    }
}
