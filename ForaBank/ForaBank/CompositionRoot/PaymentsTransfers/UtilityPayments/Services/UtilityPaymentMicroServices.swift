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
    
    typealias InitiateUtilityPayment = PrepaymentFlowEffectHandler.InitiateUtilityPayment
    
    typealias PrepaymentFlowEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
}
