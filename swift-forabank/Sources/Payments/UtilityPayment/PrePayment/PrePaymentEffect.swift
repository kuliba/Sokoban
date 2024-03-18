//
//  PrePaymentEffect.swift
//
//
//  Created by Igor Malyarov on 03.03.2024.
//

public enum PrePaymentEffect<LastPayment, Operator, Service> {
    
    case select(Select)
}

public extension PrePaymentEffect {
    
    enum Select {
        
        case last(LastPayment)
        case `operator`(Operator)
        case service(Operator, Service)
    }
}

extension PrePaymentEffect.Select: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}
extension PrePaymentEffect: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}
