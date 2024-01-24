//
//  SberQRConfirmPaymentStateOf.swift
//
//
//  Created by Igor Malyarov on 17.12.2023.
//

public enum SberQRConfirmPaymentStateOf<Info> {
    
    case editableAmount(EditableAmount)
    case fixedAmount(FixedAmount)
}

extension SberQRConfirmPaymentStateOf: Equatable where Info: Equatable {}
