//
//  ComposedOperatorsState.swift
//
//
//  Created by Дмитрий Савушкин on 19.02.2024.
//

import Foundation

public struct ComposedOperatorsState<LastPayment, Operator> {
    
    let lastPayments: [LastPayment]
    let operators: [Operator]
    let searchText: String
    
    public init(
        lastPayments: [LastPayment],
        operators: [Operator],
        searchText: String
    ) {
        self.lastPayments = lastPayments
        self.operators = operators
        self.searchText = searchText
    }
}
