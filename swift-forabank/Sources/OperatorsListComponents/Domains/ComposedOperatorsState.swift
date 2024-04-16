//
//  ComposedOperatorsState.swift
//
//
//  Created by Дмитрий Савушкин on 19.02.2024.
//

import Foundation

public struct ComposedOperatorsState {
    
    let operators: [Operator]?
    let latestPayments: [LatestPayment]?
    
    public init(
        operators: [Operator]?,
        latestPayments: [LatestPayment]?
    ) {
        self.operators = operators
        self.latestPayments = latestPayments
    }
}
