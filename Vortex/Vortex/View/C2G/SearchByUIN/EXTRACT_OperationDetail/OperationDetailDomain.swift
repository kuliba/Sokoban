//
//  OperationDetailDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.02.2025.
//

import StateMachines
import RxViewModel

enum OperationDetailDomain {}

extension OperationDetailDomain {
    
    typealias Model = RxViewModel<State, Event, Effect>
    
    typealias Reducer = StateMachines.LoadReducer<Success, Error>
    typealias EffectHandler = StateMachines.LoadEffectHandler<Success, Error>
    
    typealias State = StateMachines.LoadState<Success, Error>
    typealias Event = StateMachines.LoadEvent<Success, Error>
    typealias Effect = StateMachines.LoadEffect
    
    typealias Success = Void
    typealias Failure = Error
}
