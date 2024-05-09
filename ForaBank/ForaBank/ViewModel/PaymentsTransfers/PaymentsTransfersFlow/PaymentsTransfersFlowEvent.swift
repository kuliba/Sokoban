//
//  PaymentsTransfersFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

enum PaymentsTransfersFlowEvent<LastPayment, Operator, UtilityService> {
    
    case dismissFullScreenCover
    case goToMain
    case paymentButtonTapped(PaymentButton)
    case setModal(to: Modal)
    case utilityFlow(UtilityFlowEvent)
}

extension PaymentsTransfersFlowEvent {
    
    typealias Modal = PaymentsTransfersViewModel.Modal
    
    enum PaymentButton: Equatable {
        
        case utilityService
    }
    
    typealias UtilityFlowEvent = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>
}

//extension PaymentsTransfersFlowEvent: Equatable where LastPayment: Equatable, Operator: Equatable, UtilityService: Equatable {}
