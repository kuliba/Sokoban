//
//  GetSberQRDataResponse+Amount.swift
//
//
//  Created by Igor Malyarov on 03.12.2023.
//

import Foundation

public extension GetSberQRDataResponse.Parameter {
    
    struct Amount: Equatable {
        
        public let id: ID
        public let value: Decimal
        public let title: String
        public let validationRules: [ValidationRule]
        public let button: Button
        
        public init(
            id: ID,
            value: Decimal,
            title: String,
            validationRules: [ValidationRule],
            button: Button
        ) {
            self.id = id
            self.value = value
            self.title = title
            self.validationRules = validationRules
            self.button = button
        }
    }
}

public extension GetSberQRDataResponse.Parameter.Amount {
    
    enum ID: String, Equatable {
        
        case paymentAmount = "payment_amount"
    }
    
    struct Button: Equatable {
        
        let title: String
        let action: Action
        let color: Color
        
        public init(
            title: String,
            action: Action,
            color: Color
        ) {
            self.title = title
            self.action = action
            self.color = color
        }
    }
    
    enum Action: Equatable {
        
        case paySberQR
    }
    
    enum Color: Equatable {
        
        case red
    }
    
    struct ValidationRule: Equatable {}
}
