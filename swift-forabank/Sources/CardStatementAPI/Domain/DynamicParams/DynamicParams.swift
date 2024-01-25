//
//  DynamicParams.swift
//
//
//  Created by Andryusina Nataly on 24.01.2024.
//

import Foundation

public struct DynamicParams {
    
    public let balance: Decimal?
    public let balanceRub: Decimal?
    public let customName: String?
    public let variableParams: VariableParams
    
    public init(balance: Decimal?, balanceRub: Decimal?, customName: String?, variableParams: VariableParams) {
        self.balance = balance
        self.balanceRub = balanceRub
        self.customName = customName
        self.variableParams = variableParams
    }
}

public extension DynamicParams {
    
    enum VariableParams {
        case account(AccountDynamicParams)
        case card(CardDynamicParams)
        case deposit
        case loan
    }
}
