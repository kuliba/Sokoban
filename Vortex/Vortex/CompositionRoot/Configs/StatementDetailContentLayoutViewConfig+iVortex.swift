//
//  StatementDetailContentLayoutViewConfig+iVortex.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.02.2025.
//

import UIPrimitives

extension StatementDetailContentLayoutViewConfig {
    
    static let iVortex: Self = .init(
        formattedAmount: .init(
            textFont: .textH1Sb24322(),
            textColor: .textSecondary
        ),
        formattedDate: .init(
            textFont: .textBodySR12160(),
            textColor: .textPlaceholder
        ),
        merchantName: .init(
            textFont: .textBodyMR14180(),
            textColor: .textPlaceholder
        ),
        purpose: .init(
            textFont: .textH4M16240(),
            textColor: .textSecondary
        ),
        purposeHeight: 40,
        spacing: 24,
        status: .init(
            font: .textH4M16240(),
            completed: .systemColorActive,
            inflight: .systemColorWarning,
            rejected: .textRed
        ),
        frames: .init(
            button: .init(width: 100, height: 92),
            buttonCircle: .init(width: 56, height: 56),
            buttonText: .init(width: 66, height: 14),
            formattedAmount: .init(width: 156, height: 22),
            formattedDate: .init(width: 156, height: 12),
            logo: 64,
            purpose: .init(width: 178, height: 16),
            status: .init(width: 100, height: 10)
        ),
        placeholderColors: .init(
            button: .blurPlaceholder,
            logo: .mainColorsGrayLightest,
            text: .blurPlaceholderwhitetext
        )
    )
}
