//
//  CachedAnywayTransactionEvent.swift
//
//
//  Created by Igor Malyarov on 07.06.2024.
//

public enum CachedAnywayTransactionEvent<State, TransactionEvent> {
    
    case stateUpdate(State)
    case transaction(TransactionEvent)
}

extension CachedAnywayTransactionEvent: Equatable where State: Equatable, TransactionEvent: Equatable {}
