//
//  TransactionStatus.swift
//  
//
//  Created by Igor Malyarov on 19.05.2024.
//

public enum TransactionStatus<TransactionReport> {
    
    case fraudSuspected
    case result(TransactionResult)
    case serverError(String)
}

public extension TransactionStatus {
    
    typealias TransactionResult = Result<TransactionReport, Terminated>
    
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

extension TransactionStatus: Equatable where TransactionReport: Equatable {}
