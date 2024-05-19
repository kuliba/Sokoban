//
//  Transaction.swift
//
//
//  Created by Igor Malyarov on 30.03.2024.
//

public struct Transaction<TransactionReport, Payment> {
    
    public var payment: Payment
    public var isValid: Bool
    public var status: Status?
    
    public init(
        payment: Payment,
        isValid: Bool,
        status: Status? = nil
    ) {
        self.payment = payment
        self.isValid = isValid
        self.status = status
    }
}

public extension Transaction {
    
    typealias Status = TransactionStatus<TransactionReport>
}

extension Transaction: Equatable where TransactionReport: Equatable, Payment: Equatable {}
