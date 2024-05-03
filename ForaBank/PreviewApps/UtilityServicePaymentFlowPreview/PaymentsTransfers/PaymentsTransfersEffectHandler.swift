//
//  PaymentsTransfersEffectHandler.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

final class PaymentsTransfersEffectHandler {
    
    private let select: Select
    
    init(
        select: @escaping Select
    ) {
        self.select = select
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
    
    typealias SelectPayload = PaymentsTransfersEffect.UtilityPaymentFlowEffect.UtilityPrepaymentFlowEffect.Select
    typealias SelectResult = Int
    typealias SelectCompletion = (SelectResult) -> Void
    typealias Select = (SelectPayload, @escaping SelectCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}

private extension PaymentsTransfersEffectHandler {
    
    typealias UtilityFlowDispatch = (Event.UtilityPaymentFlowEvent) -> Void
    
    func handleEffect(
        _ effect: Effect.UtilityPaymentFlowEffect,
        _ dispatch: @escaping UtilityFlowDispatch
    ) {
        switch effect {
        case let .prepayment(effect):
            handleEffect(effect) { dispatch(.prepayment($0)) }

        }
    }
    
    typealias UtilityPrepaymentEffect = Effect.UtilityPaymentFlowEffect.UtilityPrepaymentFlowEffect
    typealias UtilityPrepaymentEvent = Event.UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent
    typealias UtilityPrepaymentDispatch = (UtilityPrepaymentEvent) -> Void
    
    func handleEffect(
        _ effect: UtilityPrepaymentEffect,
        _ dispatch: @escaping UtilityPrepaymentDispatch
    ) {
        switch effect {
        case let .select(select):
            self.select(select) { dispatch(.loaded($0)) }
        }
    }
}
