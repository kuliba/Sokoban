//
//  PaymentsTransfersFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

enum PaymentsTransfersFlowEvent<LastPayment, Operator, UtilityService> {
    
    case addCompany
    case dismissDestination
    case dismissFullScreenCover
    case dismissModal
    case goToMain
    case paymentButtonTapped(PaymentButton)
    case setModal(to: Modal)
    case utilityFlow(UtilityFlowEvent)
}

extension PaymentsTransfersFlowEvent {
    
    #warning("make `Modal` generic")
    typealias Modal = PaymentsTransfersViewModel.Modal
    
    enum PaymentButton: Equatable {
        
        case utilityService
    }
    
    typealias UtilityFlowEvent = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>
}

//extension PaymentsTransfersFlowEvent: Equatable where LastPayment: Equatable, Operator: Equatable, UtilityService: Equatable {}
