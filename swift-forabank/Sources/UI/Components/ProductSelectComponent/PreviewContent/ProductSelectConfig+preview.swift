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
        chevron: .init(
            color: .pink,
            image: .init(systemName: "chevron.up")
        ),
        footer: .init(
            textFont: .caption,
            textColor: .gray.opacity(0.5)
        ),
        header: .init(
            textFont: .footnote,
            textColor: .pink.opacity(0.5)
        ),
        missingSelected: .init(
            backgroundColor: .green,
            foregroundColor: .pink,
            image: .init(systemName: "text.justify"),
            title: .init(
                textFont: .title2,
                textColor: .orange
            )
        ),
        title: .init(
            textFont: .headline,
            textColor: .green
        ),
        carouselConfig: .preview
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
        ), 
        selectedImage: Image(systemName: "checkmark.circle.fill")
    )
}
