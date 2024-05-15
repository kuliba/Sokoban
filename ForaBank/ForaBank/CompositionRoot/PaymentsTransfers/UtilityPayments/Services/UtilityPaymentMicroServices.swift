//
//  UtilityPaymentMicroServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import UtilityServicePrepaymentCore

struct UtilityPaymentMicroServices<LastPayment, Operator>
where Operator: Identifiable {
    
    let initiateUtilityPayment: InitiateUtilityPayment
}

extension UtilityPaymentMicroServices {
    
    typealias PrepaymentFlowEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>

    typealias InitiateUtilityPaymentCompletion = PrepaymentFlowEffectHandler.InitiateUtilityPaymentCompletion
    typealias InitiateUtilityPayment = PrepaymentFlowEffectHandler.InitiateUtilityPayment
}
