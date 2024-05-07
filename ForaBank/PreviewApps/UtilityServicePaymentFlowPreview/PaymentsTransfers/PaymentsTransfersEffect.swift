//
//  PaymentsTransfersEffect.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation

enum PaymentsTransfersEffect: Equatable {
    
    case delay(PaymentsTransfersEvent, for: DispatchTimeInterval)
    case utilityFlow(UtilityPaymentFlowEffect)
}
