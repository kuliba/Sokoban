//
//  PrePaymentOptionsState.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

public struct PrePaymentOptionsState<LastPayment, Operator> {
    
    // TODO: replace Array with NonEmptyArray
    public var lastPayments: [LastPayment]?
    // TODO: replace Array with NonEmptyArray
    public var operators: [Operator]?
    public var searchText: String
    public var isInflight: Bool
    
    public init(
        lastPayments: [LastPayment]? = nil,
        operators: [Operator]? = nil,
        searchText: String = "",
        isInflight: Bool = false
    ) {
        self.lastPayments = lastPayments
        self.operators = operators
        self.searchText = searchText
        self.isInflight = isInflight
    }
}

extension PrePaymentOptionsState: Equatable where LastPayment: Equatable, Operator: Equatable {}
