//
//  AccountDynamicParams.swift
//
//
//  Created by Andryusina Nataly on 24.01.2024.
//

import Foundation

public struct AccountDynamicParams: Equatable {
    
    public let status: String
    public let balance: Decimal?
    public let balanceRub: Decimal?
    public let customName: String?
    
    public init(status: String, balance: Decimal?, balanceRub: Decimal?, customName: String?) {
        self.status = status
        self.balance = balance
        self.balanceRub = balanceRub
        self.customName = customName
    }
}
