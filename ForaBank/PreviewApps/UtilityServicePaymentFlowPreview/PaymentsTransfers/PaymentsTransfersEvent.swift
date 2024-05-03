//
//  PaymentsTransfersEvent.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

enum PaymentsTransfersEvent: Equatable {
    
    case utilityFlow(UtilityPaymentFlowEvent)
}

extension PaymentsTransfersEvent {
    
    enum UtilityPaymentFlowEvent: Equatable {
        
        case prepayment(UtilityPrepaymentFlowEvent)
    }
}

extension PaymentsTransfersEvent.UtilityPaymentFlowEvent {
    
    enum UtilityPrepaymentFlowEvent: Equatable {
        
        case addCompany
        case dismissDestination
        case loaded(Int)
        case payByInstructions
        case payByInstructionsFromError
        case select(Select)
    }
}

extension PaymentsTransfersEvent.UtilityPaymentFlowEvent {
    
    enum Select: Equatable {
        
        case lastPayment(LastPayment)
        case `operator`(Operator)
    }
}
