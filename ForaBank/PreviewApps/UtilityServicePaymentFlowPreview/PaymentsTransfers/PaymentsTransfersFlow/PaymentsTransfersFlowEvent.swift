//
//  PaymentsTransfersFlowEvent.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

enum PaymentsTransfersFlowEvent<Content, PaymentViewModel> {
    
    case dismissFullScreenCover
    case goToMain
    case paymentButtonTapped(PaymentButton)
    case setModal(to: Modal)
    case utilityFlow(UtilityPaymentFlowEvent)
}

extension PaymentsTransfersFlowEvent {
    
    typealias Route = PaymentsTransfersViewModel._Route<Content, PaymentViewModel>
    typealias Modal = Route.Modal
    
    enum PaymentButton: Equatable {
        
        case utilityService
    }
}

extension PaymentsTransfersFlowEvent: Equatable where Content: Equatable, PaymentViewModel: Equatable {}
