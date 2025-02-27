//
//  SavingsAccountDetails.swift
//
//
//  Created by Andryusina Nataly on 29.11.2024.
//

import SwiftUI

public struct SavingsAccountDetails: Equatable {
    
    public let currentInterest: Decimal
    public let minBalance: Decimal
    public let paidInterest: Decimal
    public let progress: CGFloat
    public let dateNext: String?

    public let currencyCode: String
    
    public init(
        currentInterest: Decimal,
        minBalance: Decimal,
        paidInterest: Decimal,
        progress: CGFloat,
        dateNext: String?,
        currencyCode: String
    ) {
        self.currentInterest = currentInterest
        self.minBalance = minBalance
        self.paidInterest = paidInterest
        self.progress = progress
        self.dateNext = dateNext
        self.currencyCode = currencyCode
    }
}
