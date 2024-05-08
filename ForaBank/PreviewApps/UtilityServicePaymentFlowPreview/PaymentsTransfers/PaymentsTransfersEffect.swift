//
//  PaymentsTransfersEffect.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation

enum PaymentsTransfersEffect<UtilityPrepaymentViewModel, PaymentViewModel> {
    
    case delay(Event, for: DispatchTimeInterval)
    case utilityFlow(UtilityPaymentFlowEffect)
}

extension PaymentsTransfersEffect {
    
    typealias Event = PaymentsTransfersEvent<UtilityPrepaymentViewModel, PaymentViewModel>
}

extension PaymentsTransfersEffect: Equatable where UtilityPrepaymentViewModel: Equatable, PaymentViewModel: Equatable {}
