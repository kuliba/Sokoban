//
//  SavingsAccountDetailsConfig+iVortex.swift
//  Vortex
//
//  Created by Igor Malyarov on 25.02.2025.
//

import SavingsAccount
import SwiftUI

extension SavingsAccountDetailsConfig {
    
    static let iVortex: Self = .init(
        chevronDown: .ic24ChevronDown,
        colors: .init(
            background: .textSecondary,
            chevron: .gray,
            progress: .textPrimary,
            shimmering: Color(red: 0.76, green: 0.76, blue: 0.76)),
        cornerRadius: 12,
        days: .init(textFont: .system(size: 12), textColor: .gray),
        heights: .init(
            big: 340,
            header: 24,
            interest: 20,
            period: 16,
            progress: 6,
            small: 144
        ),
        info: .init(systemName: "info.circle"),
        interestDate: .init(textFont: .system(size: 16), textColor: .white),
        interestTitle: .init(textFont: .system(size: 14), textColor: .gray),
        interestSubtitle: .init(textFont: .system(size: 16), textColor: .white),
        padding: 16,
        period: .init(textFont: .system(size: 12), textColor: .gray),
        progressColors: [
            .systemColorActive,
            Color(red: 255/255, green: 187/255, blue: 54/255),
            .buttonPrimary
        ],
        texts: .init(
            currentInterest: "Проценты текущего периода",
            header: .init(text: "Детали счета", config: .init(textFont: .system(size: 20), textColor: .white)),
            minBalance: "Минимальный остаток текущего периода",
            paidInterest: "Выплачено всего процентов",
            per: " / мес",
            days: "5 дней",
            interestDate: "Дата выплаты % - 31 мая",
            period: "Отчетный период 1 мая - 31 мая"
        )
    )
}
