//
//  Parameters+SuccessText.swift
//  
//
//  Created by Igor Malyarov on 16.12.2023.
//

public extension Parameters {
    
    struct SuccessText: Equatable {
        
        let id: CreateSberQRPaymentIDs.ID
        public let value: String
        public let style: Style
        
        public init(id: CreateSberQRPaymentIDs.ID, value: String, style: Style) {
            
            self.id = id
            self.value = value
            self.style = style
        }
    }
}
