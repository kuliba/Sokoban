//
//  RxViewModel.swift
//
//
//  Created by Igor Malyarov on 14.01.2024.
//

import Combine
import Foundation

public final class RxViewModel<State, Event, Effect>: ObservableObject {
    
    @Published public private(set) var state: State
    
    private let stateSubject = PassthroughSubject<State, Never>()
    
    private let reduce: Reduce
    private let handleEffect: HandleEffect
    
    public init(
        initialState: State,
        reduce: @escaping Reduce,
        handleEffect: @escaping HandleEffect,
        predicate: @escaping (State, State) -> Bool = { _,_ in false },
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = initialState
        self.reduce = reduce
        self.handleEffect = handleEffect
        
        stateSubject
            .removeDuplicates(by: predicate)
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

public extension RxViewModel {
    
    func event(_ event: Event) {
        
        let (state, effect) = reduce(state, event)
        stateSubject.send(state)
        
        if let effect {
            
            handleEffect(effect) { [weak self] event in
                
                self?.event(event)
            }
        }
    }
}

public extension RxViewModel {
    
    typealias Reduce = (State, Event) -> (State, Effect?)
    typealias HandleEffect = (Effect, @escaping (Event) -> Void) -> Void
}
