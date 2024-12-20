//
//  DepositOrLoanParams.swift
//  
//
//  Created by Andryusina Nataly on 25.01.2024.
//

import Foundation

public struct DepositOrLoanDynamicParams: Equatable {
    
    public let balance: Decimal?
    public let balanceRub: Decimal?
    public let customName: String?
    
    public init(balance: Decimal?, balanceRub: Decimal?, customName: String?) {
        self.balance = balance
        self.balanceRub = balanceRub
        self.customName = customName
    }
}
