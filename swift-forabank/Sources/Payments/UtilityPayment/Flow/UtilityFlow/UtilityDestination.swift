//
//  UtilityDestination.swift
//  
//
//  Created by Igor Malyarov on 15.03.2024.
//

public enum UtilityDestination<LastPayment, Operator, Service> {
    
    case failure(ServiceFailure)
    case payment
    case prepayment(Prepayment)
    case selectFailure(Operator)
    case services([Service]) // more than one
}

public extension UtilityDestination {
    
    enum Prepayment {
        
        case failure
        case options(Options)
    }
}

public extension UtilityDestination.Prepayment {
    
    typealias Options = PrepaymentOptionsState<LastPayment, Operator>
}

extension UtilityDestination: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}

extension UtilityDestination.Prepayment: Equatable where LastPayment: Equatable, Operator: Equatable {}
