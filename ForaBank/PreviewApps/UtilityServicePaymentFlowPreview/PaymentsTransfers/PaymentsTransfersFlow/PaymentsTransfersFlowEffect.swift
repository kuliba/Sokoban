//
//  PaymentsTransfersFlowEffect.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation

enum PaymentsTransfersFlowEffect: Equatable {
    
    case delay(Event, for: DispatchTimeInterval)
    case utilityFlow(UtilityPaymentFlowEffect)
}

extension PaymentsTransfersFlowEffect {
    
    typealias Event = PaymentsTransfersFlowEvent
}
