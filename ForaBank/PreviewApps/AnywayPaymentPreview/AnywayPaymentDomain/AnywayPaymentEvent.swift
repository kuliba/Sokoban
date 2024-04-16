//
//  AnywayPaymentEvent.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 13.04.2024.
//

import AnywayPaymentCore
import Foundation
import Tagged

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
        case product(ProductID, Currency)
    }
}

extension AnywayPaymentEvent.Widget {
    
    typealias Currency = Tagged<_Currency, String>
    enum _Currency {}
    
    struct ProductID: Equatable {
        
        let id: Int
        let type: ProductType
    }
}

extension AnywayPaymentEvent.Widget.ProductID {
    
    enum ProductType: Equatable {
        
        case account, card
    }
}
