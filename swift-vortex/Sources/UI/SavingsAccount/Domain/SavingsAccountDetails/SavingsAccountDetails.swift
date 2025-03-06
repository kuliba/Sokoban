//
//  SavingsAccountDetails.swift
//
//
//  Created by Andryusina Nataly on 29.11.2024.
//

import SwiftUI

public struct SavingsAccountDetails: Equatable {
    
    public let dateNext: String?
    public let dateSettlement: String?
    public let dateStart: String?
    public let daysLeft: Int?
    public let daysLeftText: String?
    public let interestAmount: Decimal?
    public let interestPaid: Decimal?
    public let isNeedTopUp: Bool?
    public let isPercentBurned: Bool?
    public let minRest: Decimal?

    public let currencyCode: String
    public let progress: CGFloat
    
    public init(
        dateNext: String?,
        dateSettlement: String?,
        dateStart: String?,
        daysLeft: Int?,
        daysLeftText: String?,
        interestAmount: Decimal?,
        interestPaid: Decimal?,
        isNeedTopUp: Bool?,
        isPercentBurned: Bool?,
        minRest: Decimal?,
        currencyCode: String,
        progress: CGFloat
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
        self.currencyCode = currencyCode
        self.progress = progress
    }
}
