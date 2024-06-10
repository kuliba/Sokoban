//
//  Transaction.swift
//
//
//  Created by Igor Malyarov on 30.03.2024.
//

public struct Transaction<Context, Status> {
    
    public var context: Context
    public var isValid: Bool
    public var status: Status?
    
    public init(
        context: Context,
        isValid: Bool,
        status: Status? = nil
    ) {
        self.context = context
        self.isValid = isValid
        self.status = status
    }
}

extension Transaction: Equatable where Context: Equatable, Status: Equatable {}
