//
//  PaymentsTransfersEvent.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

enum PaymentsTransfersEvent<Content, PaymentViewModel> {
    
    case dismissFullScreenCover
    case goToMain
    case paymentButtonTapped(PaymentButton)
    case setModal(to: Modal)
    case utilityFlow(UtilityPaymentFlowEvent)
}

extension PaymentsTransfersEvent {
    
    typealias Route = PaymentsTransfersViewModel._Route<Content, PaymentViewModel>
    typealias Modal = Route.Modal
    
    enum PaymentButton: Equatable {
        
        case utilityService
    }
}

extension PaymentsTransfersEvent: Equatable where Content: Equatable, PaymentViewModel: Equatable {}
