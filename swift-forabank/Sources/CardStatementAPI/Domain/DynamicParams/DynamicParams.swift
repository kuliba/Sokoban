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
        
        public var balance: Decimal? {
            switch self {
            case let .account(value):
                return value.balance
            case let .card(value):
                return value.balance
            case let .depositOrLoan(value):
                return value.balance
            }
        }
        
        public var balanceRub: Decimal? {
            switch self {
            case let .account(value):
                return value.balanceRub
            case let .card(value):
                return value.balanceRub
            case let .depositOrLoan(value):
                return value.balanceRub
            }
        }
        
        public var customName: String? {
            switch self {
            case let .account(value):
                return value.customName
            case let .card(value):
                return value.customName
            case let .depositOrLoan(value):
                return value.customName
            }
        }
        
        public var statusCardValue: CardDynamicParams.StatusCard? {
            switch self {
            case .account, .depositOrLoan:
                return .none
            case let .card(value):
                return value.statusCard
            }
        }
    }
}
