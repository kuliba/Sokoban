//
//  Parameters+Amount.swift
//
//
//  Created by Igor Malyarov on 16.12.2023.
//

import Foundation

public extension Parameters {
    
    struct Amount<ID> {
        
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

extension Parameters.Amount: Equatable where ID: Equatable {}

public extension Parameters.Amount {
    
    struct Button: Equatable {
        
        let title: String
        let action: Action
        let color: Parameters.Color
        
        public init(
            title: String,
            action: Action,
            color: Parameters.Color
        ) {
            self.title = title
            self.action = action
            self.color = color
        }
    }
    
    enum Action: Equatable {
        
        case paySberQR
    }
    
    struct ValidationRule: Equatable {}
}
