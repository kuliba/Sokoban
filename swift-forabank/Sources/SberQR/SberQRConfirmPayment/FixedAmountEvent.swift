//
//  FixedAmountEvent.swift
//
//
//  Created by Igor Malyarov on 07.12.2023.
//

public extension SberQRConfirmPaymentEvent {
    
    enum FixedAmountEvent {
        
        case toggleProductSelect
        case pay
        case select(ProductSelect.Product.ID)
    }
}
