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
    
    typealias ParameterID = AnywayPayment.Element.Parameter.Field.ID
    
    enum Widget: Equatable {
        
        case amount(Decimal)
        case otp(Int?)
        case product(ProductID, Currency)
    }
}

public extension AnywayPaymentEvent.Widget {
    
    typealias Currency = AnywayPayment.Element.Widget.PaymentCore.Currency
    typealias ProductID = AnywayPayment.Element.Widget.PaymentCore.ProductID
}
