//
//  PaymentsTransfersEffect.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

enum PaymentsTransfersEffect: Equatable {
    
    case utilityFlow(UtilityPaymentFlowEffect)
}

extension PaymentsTransfersEffect {
    
    enum UtilityPaymentFlowEffect: Equatable {
        
        case prepayment(UtilityPrepaymentFlowEffect)
    }
}

extension PaymentsTransfersEffect.UtilityPaymentFlowEffect {
    
    enum UtilityPrepaymentFlowEffect: Equatable {
        
        case select(Select)
    }
}

extension PaymentsTransfersEffect.UtilityPaymentFlowEffect.UtilityPrepaymentFlowEffect {
    
    typealias Select = PaymentsTransfersEvent.UtilityPaymentFlowEvent.Select
}
