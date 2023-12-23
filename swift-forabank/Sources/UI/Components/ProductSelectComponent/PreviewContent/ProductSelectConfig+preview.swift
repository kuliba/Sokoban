//
//  ProductSelectConfig+preview.swift
//
//
//  Created by Igor Malyarov on 12.12.2023.
//

import SwiftUI

public extension ProductSelectConfig {
    
    static let preview: Self = .init(
        amount: .init(
            textFont: .body,
            textColor: .purple
        ),
        card: .preview,
        chevronColor: .gray.opacity(0.4),
        footer: .init(
            textFont: .caption,
            textColor: .gray.opacity(0.5)
        ),
        header: .init(
            textFont: .footnote,
            textColor: .pink.opacity(0.5)
        ),
        title: .init(
            textFont: .headline,
            textColor: .green
        )
    )
}

extension ProductSelectConfig.Card {
    
    static let preview: Self = .init(
        amount: .init(
            textFont: .body,
            textColor: .gray
        ),
        number: .init(
            textFont: .caption,
            textColor: .pink
        ),
        title: .init(
            textFont: .body,
            textColor: .purple
        )
    )
}
