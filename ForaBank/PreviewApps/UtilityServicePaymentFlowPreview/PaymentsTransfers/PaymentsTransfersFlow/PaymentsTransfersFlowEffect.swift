//
//  PaymentsTransfersFlowEffect.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation

enum PaymentsTransfersFlowEffect<Content, PaymentViewModel> {
    
    case delay(Event, for: DispatchTimeInterval)
    case utilityFlow(UtilityPaymentFlowEffect)
}

extension PaymentsTransfersFlowEffect {
    
    typealias Event = PaymentsTransfersFlowEvent<Content, PaymentViewModel>
}

extension PaymentsTransfersFlowEffect: Equatable where Content: Equatable, PaymentViewModel: Equatable {}
