//
//  ServicePaymentFlowEffectHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.07.2024.
//

import CombineSchedulers
import Foundation

final class ServicePaymentFlowEffectHandler {
    
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(scheduler: AnySchedulerOf<DispatchQueue>) {
        
        self.scheduler = scheduler
    }
}

extension ServicePaymentFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .delay(event, for: interval):
            scheduler.delay(for: interval) { dispatch(event) }
        }
    }
}

extension ServicePaymentFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = ServicePaymentFlowEvent
    typealias Effect = ServicePaymentFlowEffect
}
