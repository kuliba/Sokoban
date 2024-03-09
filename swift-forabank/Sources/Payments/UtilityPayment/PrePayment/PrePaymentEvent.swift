//
//  PrePaymentEvent.swift
//  
//
//  Created by Igor Malyarov on 03.03.2024.
//

public enum PrePaymentEvent<LastPayment, Operator> {
    
    case addCompany
    case back
    case payByInstruction
    case scan
    case select(SelectEvent)
    case startPayment
}

public extension PrePaymentEvent {
    
    enum SelectEvent {
        
        case last(LastPayment)
        case `operator`(Operator)
    }
}

extension PrePaymentEvent: Equatable where LastPayment: Equatable, Operator: Equatable {}
extension PrePaymentEvent.SelectEvent: Equatable where LastPayment: Equatable, Operator: Equatable {}
