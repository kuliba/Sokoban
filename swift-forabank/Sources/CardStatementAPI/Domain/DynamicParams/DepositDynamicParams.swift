//
//  DepositDynamicParams.swift
//  
//
//  Created by Andryusina Nataly on 24.01.2024.
//

import Foundation

public struct DepositAndLoanDynamicParams: DynamicParams {
    
    public let balance: Decimal?
    public let balanceRub: Decimal?
    public let customName: String?
    
    public init(balance: Decimal?, balanceRub: Decimal?, customName: String?) {
        self.balance = balance
        self.balanceRub = balanceRub
        self.customName = customName
    }
}
