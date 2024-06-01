//
//  PaymentsTransfersFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

enum PaymentsTransfersFlowEvent<LastPayment, Operator, UtilityService> {
    
    case addCompany
    case dismiss(Dismiss)
    case goToMain
    case paymentButtonTapped(PaymentButton)
    case setModal(to: Modal)
    case utilityFlow(UtilityFlowEvent)
}

extension PaymentsTransfersFlowEvent {
    
    enum Dismiss {
        
        case destination
        case fullScreenCover
        case modal
    }
    
    #warning("make `Modal` generic")
    typealias Modal = PaymentsTransfersViewModel.Modal
    
    enum PaymentButton {
        
        case utilityService(LegacyPaymentPayload)
    }
    
    typealias UtilityFlowEvent = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>
}

extension PaymentsTransfersFlowEvent.PaymentButton {
    
    typealias LegacyPaymentPayload = PrepaymentEffect.LegacyPaymentPayload
    typealias PrepaymentEffect = Effect.UtilityPrepaymentFlowEffect
    typealias Effect = UtilityPaymentFlowEffect<LastPayment, Operator, UtilityService>
}
