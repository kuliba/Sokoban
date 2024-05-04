//
//  PaymentsTransfersEffectHandler.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

final class PaymentsTransfersEffectHandler {
    
    private let startPayment: StartPayment
    
    init(
        startPayment: @escaping StartPayment
    ) {
        self.startPayment = startPayment
    }
}

extension PaymentsTransfersEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .utilityFlow(effect):
            handleEffect(effect) { dispatch(.utilityFlow($0)) }
        }
    }
}

extension PaymentsTransfersEffectHandler {
    
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
    
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}

private extension PaymentsTransfersEffectHandler {
    
    typealias UtilityFlowDispatch = (UtilityPaymentFlowEvent) -> Void
    
    func handleEffect(
        _ effect: UtilityPaymentFlowEffect,
        _ dispatch: @escaping UtilityFlowDispatch
    ) {
        switch effect {
        case let .prepayment(effect):
            handleEffect(effect) { dispatch(.prepayment($0)) }
        }
    }
    
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
