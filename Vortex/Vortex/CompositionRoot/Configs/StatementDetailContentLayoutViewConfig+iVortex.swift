//
//  StatementDetailContentLayoutViewConfig+iVortex.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.02.2025.
//

extension StatementDetailContentLayoutViewConfig {
    
    static let iVortex: Self = .init(
        formattedAmount: .init(
            // TODO: need design fix - Nika
            textFont: .largeTitle,
            textColor: .orange
        ),
        formattedDate: .init(
            // TODO: need design fix - Nika
            textFont: .body,
            textColor: .orange
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
            // TODO: need design fix - Nika
            font: .title,
            completed: .orange,
            inflight: .orange,
            rejected: .orange
        )
    )
}
