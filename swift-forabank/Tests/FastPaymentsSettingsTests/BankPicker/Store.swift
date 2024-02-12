//
//  Store.swift
//
//
//  Created by Igor Malyarov on 31.12.2023.
//

import Combine

final class Store<State, Event>: ObservableObject {
    
    @Published  private(set) var state: State
    
    private let reduce: Reduce
    private let stateSubject = PassthroughSubject<State, Never>()
    
    init(
        initialState: State,
        reduce: @escaping Reduce,
        predicate: @escaping (State, State) -> Bool,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = initialState
        self.reduce = reduce
        
        stateSubject
            .removeDuplicates(by: predicate)
            .receive(on: scheduler)
            .assign(to: &$state)
    }
    
    func event(_ event: Event) {
        
        reduce(state, event) { [weak self] in
            
            self?.stateSubject.send($0)
        }
    }
}

extension Store where State: Equatable {
    
    convenience init(
        initialState: State,
        reduce: @escaping Reduce,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.init(
            initialState: initialState,
            reduce: reduce,
            predicate: ==,
            scheduler: scheduler
        )
    }
}

extension Store {
    
    typealias Completion = (State) -> Void
    typealias Reduce = (State, Event, @escaping Completion) -> Void
}
