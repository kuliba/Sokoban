//
//  PaymentsTransfersEffectHandler.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation

final class PaymentsTransfersEffectHandler {
    
    private let utilityEffectHandle: UtilityFlowEffectHandle
    
    init(
        utilityEffectHandle: @escaping UtilityFlowEffectHandle
    ) {
        self.utilityEffectHandle = utilityEffectHandle
    }
}

extension PaymentsTransfersEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .delay(event, for: interval):
            #warning("replace with scheduler!!")
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                
                dispatch(event)
            }
            
        case let .utilityFlow(effect):
            utilityEffectHandle(effect) { dispatch(.utilityFlow($0)) }
        }
    }
}

extension PaymentsTransfersEffectHandler {
    
    typealias UtilityFlowDispatch = (UtilityPaymentFlowEvent) -> Void
    typealias UtilityFlowEffectHandle = (UtilityPaymentFlowEffect, @escaping UtilityFlowDispatch) -> Void

    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}
