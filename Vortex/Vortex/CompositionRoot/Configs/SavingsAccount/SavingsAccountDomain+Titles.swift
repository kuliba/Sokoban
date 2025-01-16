//
//  SavingsAccountDomain+Titles.swift
//  Vortex
//
//  Created by Andryusina Nataly on 15.01.2025.
//

import Foundation

extension SavingsAccountDomain {
    
    struct Titles {
        
        let advantages: String
        let conditions: String
        let questions: String
    }
}

extension SavingsAccountDomain.Titles {
    
    static let iVortex: Self = .init(
        advantages: "Преимущества",
        conditions: "Основные условия",
        questions: "Часто задаваемые вопросы"
    )
}
