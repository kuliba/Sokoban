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
            button: .gray.opacity(0.2),
            logo: .gray.opacity(0.2),
            text: .gray.opacity(0.2)
        )
    )
}
