//
//  CreateSberQRPaymentResponse+SuccessText.swift
//
//
//  Created by Igor Malyarov on 10.12.2023.
//

public extension CreateSberQRPaymentResponse.Parameter {
    
    struct SuccessText: Equatable {
        
        let id: ID
        let value: String
        let style: Style
        
        public init(id: ID, value: String, style: Style) {
            
            self.id = id
            self.value = value
            self.style = style
        }
    }
}
