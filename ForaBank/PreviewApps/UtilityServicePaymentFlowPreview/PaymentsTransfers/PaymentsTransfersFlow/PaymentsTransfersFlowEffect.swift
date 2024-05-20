//
//  PaymentsTransfersFlowEffect.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation

enum PaymentsTransfersFlowEffect<LastPayment, Operator, UtilityService> {
    
    case delay(Event, for: DispatchTimeInterval)
    case utilityFlow(UtilityFlowEffect)
}

extension PaymentsTransfersFlowEffect {
    
    typealias Event = PaymentsTransfersFlowEvent<LastPayment, Operator, UtilityService>
    typealias UtilityFlowEffect = UtilityPaymentFlowEffect<LastPayment, Operator, UtilityService>
}

extension PaymentsTransfersFlowEffect: Equatable where LastPayment: Equatable, Operator: Equatable, UtilityService: Equatable {}
