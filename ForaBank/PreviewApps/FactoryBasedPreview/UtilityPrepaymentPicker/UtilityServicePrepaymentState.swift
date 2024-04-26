//
//  UtilityServicePrepaymentState.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 26.04.2024.
//

struct UtilityServicePrepaymentState: Equatable {
    
    let lastPayments: [LastPayment]
    let operators: [Operator]
}
