//
//  PrepaymentPickerState.swift
//
//
//  Created by Дмитрий Савушкин on 19.02.2024.
//

public struct PrepaymentPickerState<LastPayment, Operator> {
    
    public let lastPayments: [LastPayment]
    public var operators: [Operator]
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

extension PrepaymentPickerState: Equatable where LastPayment: Equatable, Operator: Equatable {}
