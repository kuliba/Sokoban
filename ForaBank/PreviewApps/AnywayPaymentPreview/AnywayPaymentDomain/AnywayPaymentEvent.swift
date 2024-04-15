//
//  AnywayPaymentEvent.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 13.04.2024.
//

import AnywayPaymentCore
import Foundation

enum AnywayPaymentEvent: Equatable {
    
#warning("demo only: `pay` is a higher - transaction - level event")
    case pay
    case setValue(String, for: ParameterID)
    case widget(Widget)
}

extension AnywayPaymentEvent {
    
    typealias ParameterID = AnywayPayment.Element.Parameter.Field.ID
    
    enum Widget: Equatable {
        
        case amount(Decimal)
        case otp(String)
        // case product(ProductID, Currency)
    }
}
