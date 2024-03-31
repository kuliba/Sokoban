//
//  PaymentState.swift
//
//
//  Created by Igor Malyarov on 30.03.2024.
//

public struct PaymentState<Payment, DocumentStatus, OperationDetails> {
    
    public var payment: Payment
    public var isValid: Bool
    public var status: Status?
    
    public init(
        payment: Payment,
        isValid: Bool = false,
        status: Status? = nil
    ) {
        self.payment = payment
        self.isValid = isValid
        self.status = status
    }
}

public extension PaymentState {
    
    enum Status {
        
        case fraudSuspected
        case result(Result<Report, Terminated>)
        case serverError(String)
    }
}

public extension PaymentState.Status {
    
    enum Terminated: Error, Equatable {
        
        case fraud(Fraud)
        case transactionFailure
        case updateFailure
    }
}

public extension PaymentState.Status.Terminated {
    
    enum Fraud: Equatable {
        
        case cancelled, expired
    }
}

public extension PaymentState.Status {
    
    typealias Report = TransactionReport<DocumentStatus, OperationDetails>
}

extension PaymentState: Equatable where Payment: Equatable, DocumentStatus: Equatable, OperationDetails: Equatable {}
extension PaymentState.Status: Equatable where DocumentStatus: Equatable, OperationDetails: Equatable {}
