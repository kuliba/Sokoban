//
//  UtilityPrepaymentFlowEffectHandler.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 08.05.2024.
//

final class UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService> {
    
    private let initiateUtilityPayment: InitiateUtilityPayment
    private let startPayment: StartPayment
    
    init(
        initiateUtilityPayment: @escaping InitiateUtilityPayment,
        startPayment: @escaping StartPayment
    ) {
        self.initiateUtilityPayment = initiateUtilityPayment
        self.startPayment = startPayment
    }
}

extension UtilityPrepaymentFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .initiate:
            initiateUtilityPayment { dispatch(.initiated($0)) }
            
        case let .startPayment(with: payload):
            startPayment(payload) { dispatch(.paymentStarted($0)) }
        }
    }
}

extension UtilityPrepaymentFlowEffectHandler {
    
    typealias InitiateUtilityPaymentCompletion = (Event.UtilityPrepaymentPayload) -> Void
    typealias InitiateUtilityPayment = (@escaping InitiateUtilityPaymentCompletion) -> Void
    
    // StartPayment is a micro-service, that combines
    // - `e` from LastPayment
    // - `d1`
    // - `d2e`
    // - `d3`, `d4`, `d5`
    typealias StartPaymentPayload = Effect.Select
    typealias StartPaymentResult = Event.StartPaymentResult
    typealias StartPaymentCompletion = (StartPaymentResult) -> Void
    typealias StartPayment = (StartPaymentPayload, @escaping StartPaymentCompletion) -> Void

    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>.UtilityPrepaymentFlowEvent
    typealias Effect = UtilityPaymentFlowEffect<LastPayment, Operator, UtilityService>.UtilityPrepaymentFlowEffect
}
