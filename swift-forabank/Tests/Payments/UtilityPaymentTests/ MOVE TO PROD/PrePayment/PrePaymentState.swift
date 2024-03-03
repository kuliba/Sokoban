//
//  PrePaymentState.swift
//  
//
//  Created by Igor Malyarov on 03.03.2024.
//

enum PrePaymentState: Equatable {
    
    case selected(Select)
    case selecting
}

extension PrePaymentState {
 
    enum Select: Equatable {
        
        case last(LastPayment)
        case `operator`(Operator)
    }
}
