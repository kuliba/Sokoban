//
//  TransactionFailure.swift
//  
//
//  Created by Igor Malyarov on 04.03.2024.
//

public enum TransactionFailure: Error, Equatable {
    
    case fraud(Fraud)
    case serverError(String)
    case transferError
}

public extension TransactionFailure {
    
    enum Fraud {
        
        case cancelled, expired
    }
}
