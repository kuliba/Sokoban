//
//  PaymentsTransfersEvent.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

enum PaymentsTransfersEvent<UtilityPrepaymentViewModel, PaymentViewModel> {
    
    case dismissFullScreenCover
    case goToMain
    case paymentButtonTapped(PaymentButton)
    case setModal(to: Modal)
    case utilityFlow(UtilityPaymentFlowEvent)
}

extension PaymentsTransfersEvent {
    
    typealias Route = PaymentsTransfersViewModel._Route<UtilityPrepaymentViewModel, PaymentViewModel>
    typealias Modal = Route.Modal
    
    enum PaymentButton: Equatable {
        
        case utilityService
    }
}

extension PaymentsTransfersEvent: Equatable where UtilityPrepaymentViewModel: Equatable, PaymentViewModel: Equatable {}
