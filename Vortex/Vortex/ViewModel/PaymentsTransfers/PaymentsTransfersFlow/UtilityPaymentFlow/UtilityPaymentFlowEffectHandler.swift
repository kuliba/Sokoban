//
//  UtilityPaymentFlowEffectHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

final class UtilityPaymentFlowEffectHandler<LastPayment, Operator, Service> {
    
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
    
    typealias PrepaymentEvent = UtilityPrepaymentFlowEvent<LastPayment, Operator, Service>
    typealias PrepaymentFlowDispatch = (PrepaymentEvent) -> Void
    typealias PrepaymentEffect = UtilityPrepaymentFlowEffect<LastPayment, Operator, Service>
    typealias UtilityPrepaymentFlowEffectHandle = (PrepaymentEffect, @escaping PrepaymentFlowDispatch) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, Service>
    typealias Effect = UtilityPaymentFlowEffect<LastPayment, Operator, Service>
}
