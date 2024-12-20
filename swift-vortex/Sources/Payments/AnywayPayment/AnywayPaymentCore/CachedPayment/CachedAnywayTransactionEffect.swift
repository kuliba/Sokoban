//
//  CachedAnywayTransactionEffect.swift
//
//
//  Created by Igor Malyarov on 07.06.2024.
//

public enum CachedAnywayTransactionEffect<TransactionEvent> {
    
    case event(TransactionEvent)
}

extension CachedAnywayTransactionEffect: Equatable where TransactionEvent: Equatable {}
