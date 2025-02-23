//
//  StatementDetailContentLayoutViewConfig+preview.swift
//
//
//  Created by Igor Malyarov on 23.02.2025.
//

import Foundation

extension StatementDetailContentLayoutViewConfig {
    
    static let preview: Self = .init(
        formattedAmount: .init(
            textFont: .largeTitle,
            textColor: .orange
        ),
        formattedDate: .init(
            textFont: .body,
            textColor: .orange
        ),
        logoWidth: 64,
        merchantName: .init(
            textFont: .headline,
            textColor: .pink
        ),
        purpose: .init(
            textFont: .body,
            textColor: .blue
        ),
        purposeHeight: 40,
        spacing: 24,
        status: .init(
            font: .title,
            completed: .orange,
            inflight: .orange,
            rejected: .orange
        )
    )
}
