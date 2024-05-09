//
//  UtilityPrepaymentState.swift
//  
//
//  Created by Igor Malyarov on 09.05.2024.
//

import OperatorsListComponents

struct UtilityPrepaymentState: Equatable {
    
    let lastPayments: [LastPayment]
    let operators: [Operator]
}

extension UtilityPrepaymentState {
    
    typealias LastPayment = OperatorsListComponents.LatestPayment
    typealias Operator = OperatorsListComponents.Operator
}
