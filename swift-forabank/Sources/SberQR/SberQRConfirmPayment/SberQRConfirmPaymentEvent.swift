//
//  SberQRConfirmPaymentEvent.swift
//
//
//  Created by Igor Malyarov on 07.12.2023.
//

import Foundation

public enum SberQRConfirmPaymentEvent {
    
    case editable(EditableAmountEvent)
    case fixed(FixedAmountEvent)
}

public extension SberQRConfirmPaymentEvent {
    
    enum EditableAmountEvent {
        
        case editAmount(Decimal)
        case toggleProductSelect
        case pay
        case select(ProductSelect.Product.ID)
    }
    
    enum FixedAmountEvent {
        
        case toggleProductSelect
        case pay
        case select(ProductSelect.Product.ID)
    }
}
