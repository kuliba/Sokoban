//
//  SberQRConfirmPaymentEvent.swift
//
//
//  Created by Igor Malyarov on 07.12.2023.
//

import Foundation
import PaymentComponents

public enum SberQRConfirmPaymentEvent: Equatable {
    
    case editable(EditableAmount)
    case fixed(FixedAmount)
    case pay
}

public extension SberQRConfirmPaymentEvent {
    
    enum EditableAmount: Equatable {
        
        case editAmount(Decimal)
        case productSelect(ProductSelectEvent)
    }
    
    enum FixedAmount: Equatable {
        
        case productSelect(ProductSelectEvent)
    }
}
