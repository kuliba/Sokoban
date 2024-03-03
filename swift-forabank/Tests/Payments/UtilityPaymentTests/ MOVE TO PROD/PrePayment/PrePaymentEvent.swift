//
//  PrePaymentEvent.swift
//  
//
//  Created by Igor Malyarov on 03.03.2024.
//

enum PrePaymentEvent: Equatable {
    
    case addCompany
    case scan
    case select(SelectEvent)
    case payByInstruction
}

extension PrePaymentEvent {
    
    enum SelectEvent: Equatable {
        
        case last(LastPayment)
        case `operator`(Operator)
    }
}
