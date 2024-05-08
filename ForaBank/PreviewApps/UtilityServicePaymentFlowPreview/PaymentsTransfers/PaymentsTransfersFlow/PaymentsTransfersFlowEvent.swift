//
//  PaymentsTransfersFlowEvent.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

enum PaymentsTransfersFlowEvent: Equatable {
    
    case dismissFullScreenCover
    case goToMain
    case paymentButtonTapped(PaymentButton)
    case setModal(to: Modal)
    case utilityFlow(UtilityPaymentFlowEvent)
}

extension PaymentsTransfersFlowEvent {
    
    typealias Modal = PaymentsTransfersViewModel.Modal
    
    enum PaymentButton: Equatable {
        
        case utilityService
    }
}
