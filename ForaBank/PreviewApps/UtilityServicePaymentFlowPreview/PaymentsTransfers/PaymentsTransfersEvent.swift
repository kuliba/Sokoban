//
//  PaymentsTransfersEvent.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

enum PaymentsTransfersEvent: Equatable {
    
    case utilityFlow(UtilityFlowEvent)
}

extension PaymentsTransfersEvent {
    
    enum UtilityFlowEvent: Equatable {
        
        case addCompany
        case payByInstructions
        case select(Select)
    }
}

extension PaymentsTransfersEvent.UtilityFlowEvent {
    
    enum Select: Equatable {
        
        case lastPayment(LastPayment)
        case `operator`(Operator)
    }
}
