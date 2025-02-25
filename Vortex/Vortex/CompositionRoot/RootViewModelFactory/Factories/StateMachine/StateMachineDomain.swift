//
//  StateMachineDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 25.02.2025.
//

import RxViewModel
import StateMachines

/// A namespace.
enum StateMachineDomain<Success, Failure: Error> {}

extension StateMachineDomain {
    
    typealias Model = RxViewModel<State, Event, Effect>
    
    // MARK: - Logic
    
    typealias Reducer = StateMachines.LoadReducer<Success, Failure>
    typealias EffectHandler = StateMachines.LoadEffectHandler<Success, Failure>
    
    // MARK: - (Rx)Domain
    
    typealias State = StateMachines.LoadState<Success, Failure>
    typealias Event = StateMachines.LoadEvent<Success, Failure>
    typealias Effect = StateMachines.LoadEffect
}
