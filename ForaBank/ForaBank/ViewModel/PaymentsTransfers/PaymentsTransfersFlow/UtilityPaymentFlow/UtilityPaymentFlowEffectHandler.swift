//
//  UtilityPaymentFlowEffectHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

final class UtilityPaymentFlowEffectHandler<LastPayment, Operator, UtilityService> {
    
    private let utilityPrepaymentEffectHandle: UtilityPrepaymentFlowEffectHandle
    
    init(
        utilityPrepaymentEffectHandle: @escaping UtilityPrepaymentFlowEffectHandle
    ) {
        self.utilityPrepaymentEffectHandle = utilityPrepaymentEffectHandle
    }
}

extension UtilityPaymentFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .prepayment(effect):
            utilityPrepaymentEffectHandle(effect) { dispatch(.prepayment($0)) }
        }
    }
}

extension UtilityPaymentFlowEffectHandler {
    
    typealias UtilityPrepaymentFlowDispatch = (PrepaymentEvent) -> Void
    typealias PrepaymentEvent = UtilityPrepaymentFlowEvent<LastPayment, Operator, UtilityService>
    typealias UtilityPrepaymentFlowEffectHandle = (Effect.UtilityPrepaymentFlowEffect, @escaping UtilityPrepaymentFlowDispatch) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>
    typealias Effect = UtilityPaymentFlowEffect<LastPayment, Operator, UtilityService>
}
