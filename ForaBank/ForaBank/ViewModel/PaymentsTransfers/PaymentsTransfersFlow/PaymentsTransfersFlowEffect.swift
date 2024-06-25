//
//  PaymentsTransfersFlowEffect.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import Foundation

enum PaymentsTransfersFlowEffect<LastPayment, Operator, Service> {
    
    case delay(Event, for: DispatchTimeInterval)
    case utilityFlow(UtilityFlowEffect)
}

extension PaymentsTransfersFlowEffect {
    
    typealias Event = PaymentsTransfersFlowEvent<LastPayment, Operator, Service>
    typealias UtilityFlowEffect = UtilityPaymentFlowEffect<LastPayment, Operator, Service>
}

//extension PaymentsTransfersFlowEffect: Equatable where LastPayment: Equatable, Operator: Equatable, UtilityService: Equatable {}
