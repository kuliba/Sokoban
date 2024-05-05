//
//  UtilityServicePaymentFlowEvent.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

enum UtilityServicePaymentFlowEvent: Equatable {
    
    case dismissFullScreenCover
    case dismissFraud
    case dismissPaymentError
    case fraud(FraudEvent)
    case notified(PaymentStateProjection)
}

extension UtilityServicePaymentFlowEvent {
    
    typealias PaymentStateProjection = PaymentsTransfersViewModelFactory.PaymentStateProjection
}
