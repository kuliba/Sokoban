//
//  UtilityPaymentsFlowComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import ForaTools
import Foundation

final class UtilityPaymentsFlowComposer {
    
    private let microServices: MicroServices
    
    init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
}

extension UtilityPaymentsFlowComposer {
    
    typealias MicroServices = UtilityPrepaymentFlowMicroServices<LastPayment, Operator>
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
}

extension UtilityPaymentsFlowComposer {
    
    func makeEffectHandler(
    ) -> UtilityFlowEffectHandler {
        
        let prepaymentEffectHandler = PrepaymentFlowEffectHandler(
            initiateUtilityPayment: microServices.initiateUtilityPayment,
            startPayment: microServices.startPayment
        )
        
        return .init(
            utilityPrepaymentEffectHandle: prepaymentEffectHandler.handleEffect(_:_:)
        )
    }
    
    typealias PrepaymentFlowEffectHandler = UtilityPrepaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
    
    typealias UtilityFlowEffectHandler = UtilityPaymentFlowEffectHandler<LastPayment, Operator, UtilityService>
}
