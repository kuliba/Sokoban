//
//  ProductEffect.swift
//
//
//  Created by Andryusina Nataly on 20.02.2025.
//

import Foundation

public enum ProductEffect: Equatable {
    
    case load
    case loadConfirmation(LoadConfirmationPayload)
    case orderAccount(OrderAccountPayload)
}

extension ProductEffect {
    
    public struct LoadConfirmationPayload: Equatable {
        
        public let condition: String
        public let tariff: String
        
        public init(
            condition: String,
            tariff: String
        ) {
            self.condition = condition
            self.tariff = tariff
        }
    }
}
