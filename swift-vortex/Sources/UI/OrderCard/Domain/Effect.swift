//
//  Effect.swift
//  
//
//  Created by Дмитрий Савушкин on 09.12.2024.
//

import Foundation

public enum Effect: Equatable {
    
    case load
    case loadConfirmation(LoadConfirmationPayload)
    case orderCard(OrderCardPayload)
}

extension Effect {
    
    public struct LoadConfirmationPayload: Equatable {
        
        public let condition: URL
        public let tariff: URL
        
        public init(
            condition: URL,
            tariff: URL
        ) {
            self.condition = condition
            self.tariff = tariff
        }
    }
}
