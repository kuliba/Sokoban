//
//  UtilityPaymentFlowEffectHandler.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

final class UtilityPaymentFlowEffectHandler {
    
    private let startPayment: StartPayment
    
    init(
        startPayment: @escaping StartPayment
    ) {
        self.startPayment = startPayment
    }
}

extension UtilityPaymentFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .prepayment(effect):
            handleEffect(effect) { dispatch(.prepayment($0)) }
        }
    }
}

extension UtilityPaymentFlowEffectHandler {
    
    // StartPayment is a micro-service, that combines
    // - `e` from LastPayment
    // - `d1`
    // - `d2e`
    // - `d3`, `d4`, `d5`
    typealias StartPaymentPayload = UtilityPaymentFlowEffect.UtilityPrepaymentFlowEffect.Select
    typealias StartPaymentResult = UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.StartPaymentResult
    typealias StartPaymentCompletion = (StartPaymentResult) -> Void
    typealias StartPayment = (StartPaymentPayload, @escaping StartPaymentCompletion) -> Void

    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPaymentFlowEvent
    typealias Effect = UtilityPaymentFlowEffect
}

private extension UtilityPaymentFlowEffectHandler {
    
    typealias UtilityPrepaymentEffect = UtilityPaymentFlowEffect.UtilityPrepaymentFlowEffect
    typealias UtilityPrepaymentEvent = UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent
    typealias UtilityPrepaymentDispatch = (UtilityPrepaymentEvent) -> Void
    
    func handleEffect(
        _ effect: UtilityPrepaymentEffect,
        _ dispatch: @escaping UtilityPrepaymentDispatch
    ) {
        switch effect {
        case let .startPayment(with: payload):
            startPayment(payload) {
                
                dispatch(.paymentStarted($0))
            }
        }
    }
}
