//
//  ComposedOperatorsState.swift
//
//
//  Created by Дмитрий Савушкин on 19.02.2024.
//

import Foundation

public struct ComposedOperatorsState<LastPayment, Operator> {
    
    public let lastPayments: [LastPayment]
    public let operators: [Operator]
    public let searchText: String
    
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

extension ComposedOperatorsState: Equatable where LastPayment: Equatable, Operator: Equatable {}
