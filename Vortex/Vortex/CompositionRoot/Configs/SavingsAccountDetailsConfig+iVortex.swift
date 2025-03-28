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
        clock: .ic24HistoryInactive,
        colors: .init(
            background: .textSecondary,
            chevron: .mainColorsGray,
            progress: .textPrimary,
            shimmering: .bgIconGrayLightest),
        cornerRadius: 12,
        days: .init(textFont: .textBodySR12160(), textColor: .textPlaceholder),
        heights: .init(
            big: 340,
            header: 24,
            interest: 20,
            period: 16,
            progress: 6,
            small: 130
        ),
        info: .ic24AlertCircle,
        interestDate: .init(textFont: .textH4M16240(), textColor: .textWhite),
        interestTitle: .init(textFont: .textBodySR12160(), textColor: .textPlaceholder),
        interestSubtitle: .init(textFont: .textH4M16240(), textColor: .textWhite),
        padding: 16,
        period: .init(textFont: .textBodySR12160(), textColor: .textPlaceholder),
        progressColors: [
            .systemColorActive,
            Color(red: 255/255, green: 187/255, blue: 54/255),
            .buttonPrimary
        ],
        texts: .init(
            currentInterest: "Проценты текущего периода",
            header: .init(text: "Детали счета", config: .init(textFont: .textH2Sb20282(), textColor: .white)),
            minBalance: "Минимальный остаток текущего периода",
            paidInterest: "Выплачено всего процентов",
            per: " / мес",
            days: "5 дней",
            interestDate: "Дата выплаты % - 31 мая",
            period: "Отчетный период 1 мая - 31 мая"
        )
    )
}
