//
//  AnywayTransactionViewModel.swift
//
//
//  Created by Igor Malyarov on 16.06.2024.
//

import AnywayPaymentDomain
import Combine
import Foundation

final class AnywayTransactionViewModel<Model, DocumentStatus, Response>: ObservableObject {
    
    @Published private(set) var state: State
    
    private let mapToModel: MapToModel
    private let reduce: Reduce
    private let handleEffect: HandleEffect
    private let stateSubject = PassthroughSubject<State, Never>()
    
    private var cancellable: AnyCancellable?
    
    init(
        transaction: State.Transaction,
        mapToModel: @escaping MapToModel,
        reduce: @escaping Reduce,
        handleEffect: @escaping HandleEffect,
        observe: @escaping Observe,
        predicate: @escaping (TransactionStatus?, TransactionStatus?) -> Bool = { _,_ in false },
        scheduler: AnySchedulerOfDispatchQueue = .main
    ) {
        self.state = .init(with: transaction, using: mapToModel)
        self.mapToModel = mapToModel
        self.reduce = reduce
        self.handleEffect = handleEffect
        
        let sharedSubject = stateSubject.share()
        
        sharedSubject
            .receive(on: scheduler)
            .assign(to: &$state)
        
        cancellable = sharedSubject
            .map(\.transaction.status)
            .removeDuplicates(by: predicate)
            .sink(receiveValue: observe)
    }
}

extension AnywayTransactionViewModel {
    
    func event(_ event: Event) {
        
        let (transaction, effect) = reduce(state.transaction, event)
        let state = state.updating(with: transaction, using: mapToModel)
        
        stateSubject.send(state)
        
        if let effect {
            
            handleEffect(effect) { [weak self] in self?.event($0) }
        }
    }
}

extension AnywayTransactionViewModel {
    
    typealias State = CachedModelsTransaction<Model, DocumentStatus, Response>
    typealias Event = AnywayTransactionEvent<DocumentStatus, Response>
    typealias Effect = AnywayTransactionEffect
    
    typealias MapToModel = (AnywayElement) -> Model
    
    typealias Reduce = (State.Transaction, Event) -> (State.Transaction, Effect?)
    
    typealias Dispatch = (Event) -> Void
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
    
    typealias Observe = (TransactionStatus?) -> Void
    typealias TransactionStatus = Status<DocumentStatus, Response>
}
