//
//  SavingsAccountNavTitle.swift
//  Vortex
//
//  Created by Andryusina Nataly on 27.02.2025.
//

import Foundation

struct SavingsAccountNavTitle: Equatable {
    
    let title: String
    let subtitle: String
}

extension SavingsAccountNavTitle {
    
    static let savingsAccount: Self = .init(
        title: "Накопительный счет",
        subtitle: "Накопительный в рублях"
    )
}
