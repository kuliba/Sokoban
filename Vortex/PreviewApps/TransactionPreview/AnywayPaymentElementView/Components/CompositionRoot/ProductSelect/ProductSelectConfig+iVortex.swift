//
//  ProductSelectConfig+iVortex.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import PaymentComponents
import SwiftUI

extension ProductSelectConfig {
    
    static let iVortex: Self = .init(
        amount: .secondary,
        card: .init(
            amount: .init(
                textFont: .caption,
                textColor: .black
            ),
            number: .init(
                textFont: .caption,
                textColor: .black
            ),
            title: .init(
                textFont: .caption,
                textColor: .black
            )
        ),
        chevron: .init(
            color: .gray,
            image: .init(systemName: "chevron.up")
        ),
        footer: .placeholder,
        header: .placeholder,
        missingSelected: .init(
            backgroundColor: .gray,
            foregroundColor: .gray,
            image: .init("vortexlogo"),
            title: .init(
                textFont: .headline,
                textColor: .secondary
            )
        ),
        title: .secondary
    )
}

private extension InfoComponent.InfoConfig {
    
    static let iVortex: Self = .init(
        title: .placeholder,
        value: .secondary
    )
}

extension TextConfig {
    
    static let secondary: Self = .init(
        textFont: .subheadline,
        textColor: .black
    )
    
    static let placeholder: Self = .init(
        textFont: .subheadline,
        textColor: .secondary
    )
}
