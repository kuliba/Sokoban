//
//  TransactionStatus.swift
//
//
//  Created by Igor Malyarov on 19.05.2024.
//

public enum TransactionStatus<Payment, Report> {
    
    case awaitingPaymentRestartConfirmation
    case fraudSuspected(Payment)
    case inflight
    case result(TransactionResult)
    case serverError(String)
}

public extension TransactionStatus {
    
    typealias TransactionResult = Result<Report, Terminated>
    
    enum Terminated: Error, Equatable {
        
        case fraud(Fraud)
        case transactionFailure
        case updatePaymentFailure
    }
}

public extension TransactionStatus.Terminated {
    
    enum Fraud: Equatable {
        
        case cancelled, expired
    }
}

extension TransactionStatus: Equatable where Payment: Equatable, Report: Equatable {}
