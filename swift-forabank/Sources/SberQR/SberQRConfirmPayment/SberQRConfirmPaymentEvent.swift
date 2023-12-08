//
//  SberQRConfirmPaymentEvent.swift
//
//
//  Created by Igor Malyarov on 07.12.2023.
//

import Foundation

public enum SberQRConfirmPaymentEvent: Equatable {
    
    case editable(EditableAmountEvent)
    case fixed(FixedAmountEvent)
}

public extension SberQRConfirmPaymentEvent {
    
    enum EditableAmountEvent: Equatable {
        
        case editAmount(Decimal)
        case toggleProductSelect
        case pay
        case select(ProductSelect.Product.ID)
    }
    
    enum FixedAmountEvent: Equatable {
        
        case toggleProductSelect
        case pay
        case select(ProductSelect.Product.ID)
    }
}
