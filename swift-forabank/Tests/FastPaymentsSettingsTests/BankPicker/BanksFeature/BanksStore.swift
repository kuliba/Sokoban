//
//  BanksStore.swift
//
//
//  Created by Igor Malyarov on 31.12.2023.
//

import Combine
import FastPaymentsSettings

final class BanksStore: ObservableObject {
    
    @Published private(set) var state: State
    
    private let reduce: Reduce
    private let stateSubject = PassthroughSubject<State, Never>()
    
    init(
        initialState: State,
        externalStateUpdate: ExternalStateUpdate,
        reduce: @escaping Reduce,
        predicate: @escaping (State, State) -> Bool = (==),
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = initialState
        self.reduce = reduce
        
        stateSubject
            .merge(with: externalStateUpdate)
            .removeDuplicates(by: predicate)
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

extension BanksStore {
    
    func event(_ event: Event) {
        
        stateSubject.send(reduce(state, event))
    }
}

extension BanksStore {
    
    typealias Reduce = (State, Event) -> State
    
    typealias State = Banks
    typealias Event = BanksEvent
    typealias ExternalStateUpdate = AnyPublisher<State, Never>
    typealias ApplySelection = (Set<Bank.ID>) -> Void
}

