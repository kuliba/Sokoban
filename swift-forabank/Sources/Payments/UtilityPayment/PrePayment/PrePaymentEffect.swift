//
//  PrePaymentEffect.swift
//
//
//  Created by Igor Malyarov on 03.03.2024.
//

public enum PrePaymentEffect<LastPayment, Operator> {
    
    case select(Select)
}

public extension PrePaymentEffect {
    
    enum Select {
        
        case last(LastPayment)
        case `operator`(Operator)
    }
}

extension PrePaymentEffect.Select: Equatable where LastPayment: Equatable, Operator: Equatable {}
extension PrePaymentEffect: Equatable where LastPayment: Equatable, Operator: Equatable {}
