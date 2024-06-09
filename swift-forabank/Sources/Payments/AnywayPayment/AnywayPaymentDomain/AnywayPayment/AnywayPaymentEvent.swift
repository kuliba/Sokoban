//
//  AnywayPaymentEvent.swift
//
//
//  Created by Igor Malyarov on 20.05.2024.
//

import Foundation

public enum AnywayPaymentEvent: Equatable {
    
    case setValue(String, for: ParameterID)
    case widget(Widget)
}

public extension AnywayPaymentEvent {
    
    typealias ParameterID = AnywayElement.Parameter.Field.ID
    
    enum Widget: Equatable {
        
        case amount(Decimal)
        case otp(String)
        case product(ProductID, ProductType, Currency)
    }
}

public extension AnywayPaymentEvent.Widget {
    
    typealias Currency = String
    typealias ProductID = Int
    
    enum ProductType: Equatable {
        
        case account, card
    }
}
