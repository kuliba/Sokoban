//
//  FlowHelpers.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

import Foundation
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

enum PushEvent: Equatable {
    
    case push
}

enum UpdateEvent: Equatable {
    
    case update
}

enum PushEffect: Equatable {
    
    case push
}

enum UpdateEffect: Equatable {
    
    case update
}

func makeDestination(
    lastPayments: [LastPayment] = [],
    operators: [Operator] = [],
    searchText: String = "",
    isInflight: Bool = false
) -> Destination<LastPayment, Operator> {
    
    .prepayment(.options(.init(
        lastPayments: lastPayments,
        operators: operators,
        searchText: searchText,
        isInflight: isInflight
    )))
}
