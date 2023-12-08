//
//  SberQRConfirmPaymentEvent.swift
//
//
//  Created by Igor Malyarov on 07.12.2023.
//

import Foundation

public enum SberQRConfirmPaymentEvent: Equatable {
    
    case editable(EditableAmount)
    case fixed(FixedAmount)
}

public extension SberQRConfirmPaymentEvent {
    
    enum EditableAmount: Equatable {
        
        case editAmount(Decimal)
        case toggleProductSelect
        case pay
        case select(ProductSelect.Product.ID)
    }
    
    enum FixedAmount: Equatable {
        
        case toggleProductSelect
        case pay
        case select(ProductSelect.Product.ID)
    }
}
