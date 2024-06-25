//
//  CachedAnywayTransactionReducer.swift
//
//
//  Created by Igor Malyarov on 07.06.2024.
//

import Foundation

public final class CachedAnywayTransactionReducer<Input, State, TransactionEvent> {
    
    private let update: Update
    
    public init(
        update: @escaping Update
    ) {
        self.update = update
    }
    
    public typealias Update = (State, Input) -> State
}

public extension CachedAnywayTransactionReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .stateUpdate(input):
            state = update(state, input)
            
        case let .transaction(transactionEvent):
            effect = .event(transactionEvent)
        }
        
        return (state, effect)
    }
    
    typealias Event = CachedAnywayTransactionEvent<Input, TransactionEvent>
    typealias Effect = CachedAnywayTransactionEffect<TransactionEvent>
}
