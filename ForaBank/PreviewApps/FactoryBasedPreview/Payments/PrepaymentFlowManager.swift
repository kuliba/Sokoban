//
//  PrepaymentFlowManager.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

final class PrepaymentFlowManager {
    
    let reduce: Reduce
    let handleEffect: HandleEffect
    
    init(
        reduce: @escaping Reduce,
        handleEffect: @escaping HandleEffect
    ) {
        self.reduce = reduce
        self.handleEffect = handleEffect
    }
}

extension PrepaymentFlowManager {

    typealias Reduce = (State, Event) -> (State, Effect?)
    typealias HandleEffect = (Effect, @escaping (Event) -> Void) -> Void

    typealias State = PrepaymentFlowState
    typealias Event = PrepaymentFlowEvent
    typealias Effect = PrepaymentFlowEffect
}
