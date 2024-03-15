//
//  Destination.swift
//  
//
//  Created by Igor Malyarov on 15.03.2024.
//

import PrePaymentPicker

enum Destination<LastPayment, Operator> {
    
    case prepayment(Prepayment)
    case services
}

extension Destination {
    
    enum Prepayment {
        
        case failure
        case options(Options)
    }
}

extension Destination.Prepayment {
    
    typealias Options = PrePaymentOptionsState<LastPayment, Operator>
}

extension Destination: Equatable where LastPayment: Equatable, Operator: Equatable {}

extension Destination.Prepayment: Equatable where LastPayment: Equatable, Operator: Equatable {}
