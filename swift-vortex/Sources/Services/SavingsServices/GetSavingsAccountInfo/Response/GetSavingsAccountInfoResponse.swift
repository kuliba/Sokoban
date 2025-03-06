//
//  GetSavingsAccountInfoResponse.swift
//  
//
//  Created by Andryusina Nataly on 05.03.2025.
//

import Foundation

public struct GetSavingsAccountInfoResponse: Equatable {
    
    public let dateNext: String?
    public let dateSettlement: String?
    public let dateStart: String?
    public let daysLeft: Int?
    public let daysLeftText: String?
    public let interestAmount: Double?
    public let interestPaid: Double?
    public let isNeedTopUp: Bool?
    public let isPercentBurned: Bool?
    public let minRest: Double?

    public init(
        dateNext: String?,
        dateSettlement: String?,
        dateStart: String?,
        daysLeft: Int?,
        daysLeftText: String?,
        interestAmount: Double?,
        interestPaid: Double?,
        isNeedTopUp: Bool?,
        isPercentBurned: Bool?,
        minRest: Double?
    ) {
        self.dateNext = dateNext
        self.dateSettlement = dateSettlement
        self.dateStart = dateStart
        self.daysLeft = daysLeft
        self.daysLeftText = daysLeftText
        self.interestAmount = interestAmount
        self.interestPaid = interestPaid
        self.isNeedTopUp = isNeedTopUp
        self.isPercentBurned = isPercentBurned
        self.minRest = minRest
    }
}
