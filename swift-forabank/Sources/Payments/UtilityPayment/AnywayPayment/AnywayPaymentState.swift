//
//  AnywayPaymentState.swift
//  
//
//  Created by Igor Malyarov on 04.03.2024.
//

public enum AnywayPaymentState<Payment> {
    
    case payment(Payment)
    case result(TransferResult)
}

public extension AnywayPaymentState {
    
    typealias TransferResult = Result<Transaction, TransactionFailure>
}

extension AnywayPaymentState: Equatable where Payment: Equatable {}
