//
//  CardDynamicParams.swift
//  
//
//  Created by Andryusina Nataly on 24.01.2024.
//

import Foundation

public struct CardDynamicParams: Equatable {
    
    public let balance: Decimal?
    public let balanceRub: Decimal?
    public let customName: String?
    public let availableExceedLimit: Decimal?
    public let status: String
    public let debtAmount: Decimal?
    public let totalDebtAmount: Decimal?
    public let statusPc: String
    public let statusCard: StatusCard
    
    public init(balance: Decimal?, balanceRub: Decimal?, customName: String?, availableExceedLimit: Decimal?, status: String, debtAmount: Decimal?, totalDebtAmount: Decimal?, statusPc: String, statusCard: StatusCard) {
        self.balance = balance
        self.balanceRub = balanceRub
        self.customName = customName
        self.availableExceedLimit = availableExceedLimit
        self.status = status
        self.debtAmount = debtAmount
        self.totalDebtAmount = totalDebtAmount
        self.statusPc = statusPc
        self.statusCard = statusCard
    }
}

extension CardDynamicParams {
    
    public enum StatusCard: Equatable {
        
        case active
        case blockedUlockAvailable
        case blockedUlockNotAvailable
        case notActivated
    }
}
