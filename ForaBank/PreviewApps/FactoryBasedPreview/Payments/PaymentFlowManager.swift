//
//  PaymentFlowManager.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

final class PaymentFlowManager {
    
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

extension PaymentFlowManager {

    typealias Reduce = (State, Event) -> (State, Effect?)
    typealias HandleEffect = (Effect, @escaping (Event) -> Void) -> Void

    typealias State = PaymentFlowState
    typealias Event = PaymentFlowEvent
    typealias Effect = PaymentFlowEffect
}
