//
//  Parameters+SuccessText.swift
//  
//
//  Created by Igor Malyarov on 16.12.2023.
//

public extension Parameters {
    
    struct SuccessText: Equatable {
        
        public typealias ID = CreateSberQRPaymentIDs.SuccessTextID
        
        let id: ID
        public let value: String
        public let style: Style
        
        public init(id: ID, value: String, style: Style) {
            
            self.id = id
            self.value = value
            self.style = style
        }
    }
}
