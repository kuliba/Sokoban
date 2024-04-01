//
//  Transaction.swift
//
//
//  Created by Igor Malyarov on 30.03.2024.
//

public struct Transaction<DocumentStatus, OperationDetails, Payment> {
    
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
    
    enum Status {
        
        case fraudSuspected
        case result(Result<Report, Terminated>)
        case serverError(String)
    }
}

public extension Transaction.Status {
    
    enum Terminated: Error, Equatable {
        
        case fraud(Fraud)
        case transactionFailure
        case updatePaymentFailure
    }
}

public extension Transaction.Status.Terminated {
    
    enum Fraud: Equatable {
        
        case cancelled, expired
    }
}

public extension Transaction.Status {
    
    typealias Report = TransactionReport<DocumentStatus, OperationDetails>
}

extension Transaction: Equatable where Payment: Equatable, DocumentStatus: Equatable, OperationDetails: Equatable {}
extension Transaction.Status: Equatable where DocumentStatus: Equatable, OperationDetails: Equatable {}
