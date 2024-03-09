//
//  PrePaymentEffect.swift
//
//
//  Created by Igor Malyarov on 03.03.2024.
//

public enum PrePaymentEffect<LastPayment, Operator> {
    
    case startPayment(StartPaymentPayload)
}

public extension PrePaymentEffect {
    
    enum StartPaymentPayload {
        
        case last(LastPayment)
        case `operator`(Operator)
    }
}

extension PrePaymentEffect.StartPaymentPayload: Equatable where LastPayment: Equatable, Operator: Equatable {}
extension PrePaymentEffect: Equatable where LastPayment: Equatable, Operator: Equatable {}
