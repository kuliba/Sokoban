//
//  RxViewModel+makeStateMachine.swift
//  Vortex
//
//  Created by Igor Malyarov on 25.02.2025.
//

import CombineSchedulers
import Foundation
import RxViewModel

extension RxViewModel {
    
    static func makeStateMachine<Success, Failure: Error>(
        initialState: StateMachineDomain<Success, Failure>.State = .pending,
        load: @escaping (@escaping (Result<Success, Failure>) -> Void) -> Void,
        predicate: @escaping (StateMachineDomain<Success, Failure>.State, StateMachineDomain<Success, Failure>.State) -> Bool = { _,_ in false },
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> StateMachineDomain<Success, Failure>.Model {
        
        let reducer = StateMachineDomain<Success, Failure>.Reducer()
        let effectHandler = StateMachineDomain<Success, Failure>.EffectHandler(load: load)
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            predicate: predicate,
            scheduler: scheduler
        )
    }
    
    static func makeStateMachine<Success, Failure: Error>(
        initialState: StateMachineDomain<Success, Failure>.State = .pending,
        load: @escaping (@escaping (Result<Success, Failure>) -> Void) -> Void,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> StateMachineDomain<Success, Failure>.Model
    where Success: Equatable, Failure: Equatable {
        
        let reducer = StateMachineDomain<Success, Failure>.Reducer()
        let effectHandler = StateMachineDomain<Success, Failure>.EffectHandler(load: load)
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            predicate: ==,
            scheduler: scheduler
        )
    }
}
