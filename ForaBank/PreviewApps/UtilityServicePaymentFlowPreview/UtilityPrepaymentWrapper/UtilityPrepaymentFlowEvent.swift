//
//  UtilityPrepaymentFlowEvent.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

enum UtilityPrepaymentFlowEvent: Equatable {
    
    case addCompany
    case payByInstructions
    case select(Select)
}

extension UtilityPrepaymentFlowEvent {
    
    enum Select: Equatable {
        
        case lastPayment(LastPayment)
        case `operator`(Operator)
    }
}
