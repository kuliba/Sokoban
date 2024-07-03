//
//  PaymentsTransfersFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

enum PaymentsTransfersFlowEvent<LastPayment, Operator, Service> {
    
    case dismiss(Dismiss)
    case outside(Outside)
    case paymentButtonTapped(PaymentButton)
    case paymentTrigger(PaymentTriggerEvent)
    case setModal(to: Modal)
    case utilityFlow(UtilityFlowEvent)
}

enum PaymentTriggerEvent: Equatable {
    
    case latestPayment(LatestPaymentData)
}

enum PaymentTriggerState: Equatable {
    
    case legacy(Legacy)
    case v1
    
    enum Legacy: Equatable {
        
        case latestPayment(LatestPaymentData)
    }
}

extension PaymentsTransfersFlowEvent {
    
    enum Dismiss {
        
        case destination
        case fullScreenCover
        case modal
    }
    
    typealias Modal = PaymentsTransfersViewModel.Modal
    
    enum Outside {
        
        case addCompany
        case goToMain
    }
    
    enum PaymentButton {
        
        case utilityService(LegacyPaymentPayload)
    }
    
    typealias UtilityFlowEvent = UtilityPaymentFlowEvent<LastPayment, Operator, Service>
}

extension PaymentsTransfersFlowEvent.PaymentButton {
    
    typealias LegacyPaymentPayload = PrepaymentEffect.LegacyPaymentPayload
    typealias PrepaymentEffect = UtilityPrepaymentFlowEffect<LastPayment, Operator, Service>
}
