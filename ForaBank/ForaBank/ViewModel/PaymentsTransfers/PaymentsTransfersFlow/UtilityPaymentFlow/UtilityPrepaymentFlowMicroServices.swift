//
//  UtilityPrepaymentFlowMicroServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import UtilityServicePrepaymentCore

struct UtilityPrepaymentFlowMicroServices<LastPayment, Operator, Service> {
    
    /// For `legacy` `InitiateUtilityPayment` wraps `PaymentsServicesViewModel` creation
    /// For `v1` `InitiateUtilityPayment` combines
    /// - `b`: getOperatorsListByParam
    /// - `c`: getAllLatestPayments
    let initiateUtilityPayment: InitiateUtilityPayment
    
    /// `ProcessSelection` combines
    /// - `e` from LastPayment
    /// - `d1`
    /// - `d2e`
    /// - `d3`, `d4`, `d5`
    let processSelection: ProcessSelection
}

extension UtilityPrepaymentFlowMicroServices {
    
    typealias InitiateUtilityPaymentCompletion = (Event.Initiated) -> Void
    /// Combines `b` and `c` for `v1`
    typealias InitiateUtilityPayment = (Effect.LegacyPaymentPayload, @escaping InitiateUtilityPaymentCompletion) -> Void
    
    /// `ProcessSelection` is a micro-service, that combines
    /// - `e` from LastPayment
    /// - `d1`
    /// - `d2e`
    /// - `d3`, `d4`, `d5`
    typealias ProcessSelectionPayload = Effect.Select
    typealias ProcessSelectionResult = Event.ProcessSelectionResult
    typealias ProcessSelectionCompletion = (ProcessSelectionResult) -> Void
    typealias ProcessSelection = (ProcessSelectionPayload, @escaping ProcessSelectionCompletion) -> Void
    
    typealias Event = UtilityPrepaymentFlowEvent<LastPayment, Operator, Service>
    typealias Effect = UtilityPrepaymentFlowEffect<LastPayment, Operator, Service>
}
