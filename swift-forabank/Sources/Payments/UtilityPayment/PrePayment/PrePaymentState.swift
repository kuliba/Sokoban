//
//  PrePaymentState.swift
//  
//
//  Created by Igor Malyarov on 03.03.2024.
//

public enum PrePaymentState: Equatable {
    
    case addingCompany
    case payingByInstruction
    case scanning
    case selected(Selected)
    case selecting
}

public extension PrePaymentState {
 
    enum Selected: Equatable {
        
        case last(LastPayment)
        case `operator`(Operator)
    }
}
