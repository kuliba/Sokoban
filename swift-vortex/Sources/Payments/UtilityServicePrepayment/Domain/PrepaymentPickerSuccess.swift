//
//  PrepaymentPickerSuccess.swift
//  
//
//  Created by Igor Malyarov on 02.07.2024.
//

public struct PrepaymentPickerSuccess<LastPayment, Operator> {
    
    public let lastPayments: [LastPayment]
    public var operators: [Operator]
    public var searchText: String
    
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

extension PrepaymentPickerSuccess: Equatable where LastPayment: Equatable, Operator: Equatable {}
