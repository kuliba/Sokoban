//
//  CardDynamicParams.swift
//  
//
//  Created by Andryusina Nataly on 24.01.2024.
//

import Foundation

public struct CardDynamicParams {
    
    public let availableExceedLimit: Decimal?
    public let status: String
    public let debtAmount: Decimal?
    public let totalDebtAmount: Decimal?
    public let statusPc: String
    public let statusCard: StatusCard
    
    public init(availableExceedLimit: Decimal?, status: String, debtAmount: Decimal?, totalDebtAmount: Decimal?, statusPc: String, statusCard: StatusCard) {
        self.availableExceedLimit = availableExceedLimit
        self.status = status
        self.debtAmount = debtAmount
        self.totalDebtAmount = totalDebtAmount
        self.statusPc = statusPc
        self.statusCard = statusCard
    }
}

extension CardDynamicParams {
    
    public enum StatusCard {
        
        case active
        case blockedUlockAvailable
        case blockedUlockNotAvailable
        case notActivated
    }
}
