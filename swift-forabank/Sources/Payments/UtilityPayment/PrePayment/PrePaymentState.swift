//
//  PrePaymentState.swift
//  
//
//  Created by Igor Malyarov on 03.03.2024.
//

public enum PrePaymentState<LastPayment, Operator> {
    
    case addingCompany
    case payingByInstruction
    case scanning
    case selected(Selected)
    case selecting
}

public extension PrePaymentState {
 
    enum Selected {
        
        case last(LastPayment)
        case `operator`(Operator)
    }
}

extension PrePaymentState: Equatable where LastPayment: Equatable, Operator: Equatable {}
extension PrePaymentState.Selected: Equatable where LastPayment: Equatable, Operator: Equatable {}
