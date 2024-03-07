//
//  AnywayPaymentState.swift
//  
//
//  Created by Igor Malyarov on 04.03.2024.
//

public enum AnywayPaymentState<UtilityPayment: Equatable>: Equatable {
    
    case payment(UtilityPayment)
    case result(TransferResult)
}

public extension AnywayPaymentState {
    
    typealias TransferResult = Result<Transaction, TransactionFailure>
}
