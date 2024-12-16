//
//  UtilityPrepaymentCompletionEvent.swift
//
//
//  Created by Igor Malyarov on 09.05.2024.
//

enum UtilityPrepaymentCompletionEvent: Equatable {
    
    case addCompany
    case payByInstructions
    case payByInstructionsFromError
    case select(Select)
}

extension UtilityPrepaymentCompletionEvent {
    
    enum Select: Equatable {
        
        case lastPayment(LastPayment)
        case `operator`(Operator)
    }
}

extension UtilityPrepaymentCompletionEvent.Select {
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
}
