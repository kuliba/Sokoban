//
//  FlowHelpers.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

import Foundation

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
