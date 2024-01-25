//
//  DynamicParams.swift
//
//
//  Created by Andryusina Nataly on 24.01.2024.
//

import Foundation

public struct DynamicParams: Equatable {
    
    public let variableParams: VariableParams
    
    public init(variableParams: VariableParams) {
        self.variableParams = variableParams
    }
}

public extension DynamicParams {
    
    enum VariableParams: Equatable {
        case account(AccountDynamicParams)
        case card(CardDynamicParams)
        case depositOrLoan(DepositOrLoanDynamicParams)
    }
}
