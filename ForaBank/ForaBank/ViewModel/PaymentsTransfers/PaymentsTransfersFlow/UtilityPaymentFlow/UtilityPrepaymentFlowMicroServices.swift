//
//  UtilityPrepaymentFlowMicroServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import UtilityServicePrepaymentCore

struct UtilityPrepaymentFlowMicroServices<LastPayment, Operator, UtilityService> {
    
    /// For `legacy` `InitiateUtilityPayment` wraps `PaymentsServicesViewModel` creation
    /// For `v1` `InitiateUtilityPayment` combines
    /// - `b`: getOperatorsListByParam
    /// - `c`: getAllLatestPayments
    let initiateUtilityPayment: InitiateUtilityPayment
    
    /// `StartPayment` combines
    /// - `e` from LastPayment
    /// - `d1`
    /// - `d2e`
    /// - `d3`, `d4`, `d5`
    let startPayment: StartPayment
}

extension UtilityPrepaymentFlowMicroServices {
    
    typealias InitiateUtilityPaymentCompletion = (PrepaymentEvent.Initiated) -> Void
    /// Combines `b` and `c` for `v1`
    typealias InitiateUtilityPayment = (PrepaymentEffect.LegacyPaymentPayload, @escaping InitiateUtilityPaymentCompletion) -> Void
    
    /// StartPayment is a micro-service, that combines
    /// - `e` from LastPayment
    /// - `d1`
    /// - `d2e`
    /// - `d3`, `d4`, `d5`
    typealias StartPaymentPayload = PrepaymentEffect.Select
    typealias StartPaymentResult = PrepaymentEvent.StartPaymentResult
    typealias StartPaymentCompletion = (StartPaymentResult) -> Void
    typealias StartPayment = (StartPaymentPayload, @escaping StartPaymentCompletion) -> Void
    
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>
    typealias PrepaymentEvent = Event.UtilityPrepaymentFlowEvent
    
    typealias Effect = UtilityPaymentFlowEffect<LastPayment, Operator, UtilityService>
    typealias PrepaymentEffect = Effect.UtilityPrepaymentFlowEffect
}
