//
//  SberQRConfirmPaymentEvent.swift
//
//
//  Created by Igor Malyarov on 07.12.2023.
//

public enum SberQRConfirmPaymentEvent {
    
    case editable(EditableAmountEvent)
    case fixed(FixedAmountEvent)
}
