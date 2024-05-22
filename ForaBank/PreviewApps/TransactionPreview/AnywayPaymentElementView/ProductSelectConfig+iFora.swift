//
//  ProductSelectConfig+iFora.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import PaymentComponents
import SwiftUI

extension ProductSelectConfig {
    
    static let iFora: Self = .init(
        amount: .secondary,
        card: .init(
            amount: .init(
                textFont: .body,
                textColor: .white
            ),
            number: .init(
                textFont: .body,
                textColor: .white
            ),
            title: .init(
                textFont: .body,
                textColor: .gray
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
            image: .init("foralogo"),
            title: .init(
                textFont: .headline,
                textColor: .secondary
            )
        ),
        title: .secondary
    )
}

private extension InfoComponent.InfoConfig {
    
    static let iFora: Self = .init(
        title: .placeholder,
        value: .secondary
    )
}

extension TextConfig {
    
    static let secondary: Self = .init(
        textFont: .body,
        textColor: .black
    )
    
    static let placeholder: Self = .init(
        textFont: .body,
        textColor: .secondary
    )
}
