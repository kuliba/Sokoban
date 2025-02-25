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
        logoWidth: 64,
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
        )
    )
}
