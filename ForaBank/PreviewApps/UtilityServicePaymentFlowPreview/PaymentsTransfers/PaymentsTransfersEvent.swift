//
//  PaymentsTransfersEvent.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

enum PaymentsTransfersEvent: Equatable {
    
    case dismissFullScreenCover
    case goToMain
    case paymentButtonTapped(PaymentButton)
    case setModal(to: Modal)
    case utilityFlow(UtilityPaymentFlowEvent)
}

extension PaymentsTransfersEvent {
    
    typealias Modal = PaymentsTransfersViewModel.State.Route.Modal
    
    enum PaymentButton: Equatable {
        
        case utilityService
    }
}
