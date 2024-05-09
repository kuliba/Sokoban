//
//  UtilityPrepaymentFlowEvent.swift
//
//
//  Created by Igor Malyarov on 09.05.2024.
//


import OperatorsListComponents

enum UtilityPrepaymentFlowEvent: Equatable {
    
    case addCompany
    case payByInstructions
    case payByInstructionsFromError
    case select(Select)
}

extension UtilityPrepaymentFlowEvent {
    
    enum Select: Equatable {
        
        case lastPayment(LastPayment)
        case `operator`(Operator)
    }
}

extension UtilityPrepaymentFlowEvent.Select {
    
    typealias LastPayment = OperatorsListComponents.LatestPayment
    typealias Operator = OperatorsListComponents.Operator
}
