//
//  UtilityDestination.swift
//  
//
//  Created by Igor Malyarov on 15.03.2024.
//

import PrePaymentPicker

public enum UtilityDestination<LastPayment, Operator> {
    
    case failure(ServiceFailure)
    case payment
    case prepayment(Prepayment)
    case services
}

public extension UtilityDestination {
    
    enum Prepayment {
        
        case failure
        case options(Options)
    }
}

public extension UtilityDestination.Prepayment {
    
    typealias Options = PrePaymentOptionsState<LastPayment, Operator>
}

extension UtilityDestination: Equatable where LastPayment: Equatable, Operator: Equatable {}

extension UtilityDestination.Prepayment: Equatable where LastPayment: Equatable, Operator: Equatable {}
