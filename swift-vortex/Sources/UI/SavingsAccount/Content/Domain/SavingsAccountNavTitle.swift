//
//  SavingsAccountNavTitle.swift
//  
//
//  Created by Andryusina Nataly on 30.01.2025.
//

import Foundation

public struct SavingsAccountNavTitle: Equatable {
    
    public let title: String
    public let subtitle: String
    
    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}

public extension SavingsAccountNavTitle {
    
    static let savingsAccount: Self = .init(
        title: "Накопительный счет",
        subtitle: "Накопительный в рублях"
    )
    
    static let empty: Self = .init(
        title: "",
        subtitle: ""
    )
    
    static let openSavingsAccount: Self = .init(
        title: "Оформление накопительного счета",
        subtitle: "")
}
