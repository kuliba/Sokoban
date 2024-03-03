//
//  PrePaymentEvent.swift
//  
//
//  Created by Igor Malyarov on 03.03.2024.
//

enum PrePaymentEvent: Equatable {
    
    case select(Select)
    case scan
    case addCompany
    case payByInstruction
}

extension PrePaymentEvent {
    
    enum Select: Equatable {
        
        case last(LastPayment)
        case `operator`(Operator)
    }
}
