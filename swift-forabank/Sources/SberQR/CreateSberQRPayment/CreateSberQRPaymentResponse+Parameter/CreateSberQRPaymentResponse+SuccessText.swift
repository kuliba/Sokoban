//
//  CreateSberQRPaymentResponse+SuccessText.swift
//
//
//  Created by Igor Malyarov on 10.12.2023.
//

public extension CreateSberQRPaymentResponse.Parameter {
    
#warning("move to Parameters, replace with typealias")
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
