//
//  SavingsAccountDetails.swift
//
//
//  Created by Andryusina Nataly on 29.11.2024.
//

import SwiftUI

public struct SavingsAccountDetails: Equatable {
    
    let currentInterest: Decimal
    let minBalance: Decimal
    let paidInterest: Decimal
    let progress: CGFloat

    let currencyCode: String
}
