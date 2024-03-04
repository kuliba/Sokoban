//
//  UtilityPaymentState.swift
//  
//
//  Created by Igor Malyarov on 04.03.2024.
//

public enum UtilityPaymentState: Equatable {
    
    case payment(UtilityPayment)
    case result(TransferResult)
}
