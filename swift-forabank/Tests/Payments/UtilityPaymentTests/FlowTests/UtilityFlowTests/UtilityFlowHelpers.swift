//
//  UtilityFlowHelpers.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

import UtilityPayment

func makeDestination(
    lastPayments: [LastPayment] = [],
    operators: [Operator] = [],
    searchText: String = "",
    isInflight: Bool = false
) -> UtilityDestination<LastPayment, Operator> {
    
    .prepayment(.options(.init(
        lastPayments: lastPayments,
        operators: operators,
        searchText: searchText,
        isInflight: isInflight
    )))
}
