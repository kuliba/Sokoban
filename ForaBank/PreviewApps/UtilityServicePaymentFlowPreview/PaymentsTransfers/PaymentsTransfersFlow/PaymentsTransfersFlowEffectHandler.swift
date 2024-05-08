//
//  PaymentsTransfersFlowEffectHandler.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation

final class PaymentsTransfersFlowEffectHandler<Content, PaymentViewModel> {
    
    private let utilityEffectHandle: UtilityFlowEffectHandle
    
    init(
        utilityEffectHandle: @escaping UtilityFlowEffectHandle
    ) {
        self.utilityEffectHandle = utilityEffectHandle
    }
}

extension PaymentsTransfersFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .delay(event, for: interval):
            #warning("replace with scheduler!!")
            DispatchQueue.main.delay(for: interval) { dispatch(event) }
            
        case let .utilityFlow(effect):
            utilityEffectHandle(effect) { dispatch(.utilityFlow($0)) }
        }
    }
}

extension PaymentsTransfersFlowEffectHandler {
    
    typealias UtilityFlowDispatch = (UtilityPaymentFlowEvent) -> Void
    typealias UtilityFlowEffectHandle = (UtilityPaymentFlowEffect, @escaping UtilityFlowDispatch) -> Void

    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersFlowEvent<Content, PaymentViewModel>
    typealias Effect = PaymentsTransfersFlowEffect<Content, PaymentViewModel>
}
