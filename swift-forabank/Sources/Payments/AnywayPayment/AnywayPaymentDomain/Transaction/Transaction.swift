//
//  Transaction.swift
//
//
//  Created by Igor Malyarov on 30.03.2024.
//

public struct Transaction<Payment, Status> {
    
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

extension Transaction: Equatable where Payment: Equatable, Status: Equatable {}
