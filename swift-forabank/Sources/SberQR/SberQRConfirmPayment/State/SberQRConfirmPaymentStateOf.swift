//
//  SberQRConfirmPaymentStateOf.swift
//
//
//  Created by Igor Malyarov on 17.12.2023.
//

public enum SberQRConfirmPaymentStateOf<Info> {
    
    case editableAmount(EditableAmount<Info>)
    case fixedAmount(FixedAmount<Info>)
}

extension SberQRConfirmPaymentStateOf: Equatable where Info: Equatable {}
