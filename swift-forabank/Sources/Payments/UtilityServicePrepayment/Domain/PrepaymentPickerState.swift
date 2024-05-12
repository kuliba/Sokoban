//
//  PrepaymentPickerState.swift
//
//
//  Created by Дмитрий Савушкин on 19.02.2024.
//

public struct PrepaymentPickerState<LastPayment, Operator> {
    
    public let lastPayments: [LastPayment]
    public var operators: [Operator]
    public var searchText: String
    public var isSearching: Bool
    
    public init(
        lastPayments: [LastPayment],
        operators: [Operator],
        searchText: String,
        isSearching: Bool = false
    ) {
        self.lastPayments = lastPayments
        self.operators = operators
        self.searchText = searchText
        self.isSearching = isSearching
    }
}

extension PrepaymentPickerState: Equatable where LastPayment: Equatable, Operator: Equatable {}
