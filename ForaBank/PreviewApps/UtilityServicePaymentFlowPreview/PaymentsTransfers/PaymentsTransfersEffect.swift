//
//  PaymentsTransfersEffect.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation

enum PaymentsTransfersEffect<Content, PaymentViewModel> {
    
    case delay(Event, for: DispatchTimeInterval)
    case utilityFlow(UtilityPaymentFlowEffect)
}

extension PaymentsTransfersEffect {
    
    typealias Event = PaymentsTransfersEvent<Content, PaymentViewModel>
}

extension PaymentsTransfersEffect: Equatable where Content: Equatable, PaymentViewModel: Equatable {}
