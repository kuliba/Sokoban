//
//  CachedAnywayTransactionEffectHandler.swift
//
//
//  Created by Igor Malyarov on 07.06.2024.
//

import AnywayPaymentDomain
import Combine

public final class CachedAnywayTransactionEffectHandler<State, TransactionEvent> {
    
    private let statePublisher: AnyPublisher<State, Never>
    private let eventHandler: (TransactionEvent) -> Void
    
    private var cancellable: AnyCancellable?
    
    public init(
        statePublisher: AnyPublisher<State, Never>,
        event: @escaping (TransactionEvent) -> Void
    ) {
        self.statePublisher = statePublisher
        self.eventHandler = event
    }
}

public extension CachedAnywayTransactionEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .event(transactionEvent):
            self.eventHandler(transactionEvent)
            self.cancellable = statePublisher
                .sink { dispatch(.stateUpdate($0)) }
        }
    }
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = CachedAnywayTransactionEvent<State, TransactionEvent>
    typealias Effect = CachedAnywayTransactionEffect<TransactionEvent>
}
