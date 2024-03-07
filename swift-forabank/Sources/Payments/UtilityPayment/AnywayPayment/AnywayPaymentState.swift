//
//  AnywayPaymentState.swift
//  
//
//  Created by Igor Malyarov on 04.03.2024.
//

public enum AnywayPaymentState<Payment: Equatable>: Equatable {
    
    case payment(Payment)
    case result(TransferResult)
}

public extension AnywayPaymentState {
    
    typealias TransferResult = Result<Transaction, TransactionFailure>
}
