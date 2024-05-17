//
//  UtilityPrepaymentFlowMicroServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import UtilityServicePrepaymentCore

struct UtilityPrepaymentFlowMicroServices<LastPayment, Operator> {
    
    /// `InitiateUtilityPayment` combines
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
    
    typealias InitiateUtilityPayment = PrepaymentFlowEffectHandler.InitiateUtilityPayment

    typealias StartPayment = PrepaymentFlowEffectHandler.StartPayment
    
    typealias PrepaymentFlowEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
}
