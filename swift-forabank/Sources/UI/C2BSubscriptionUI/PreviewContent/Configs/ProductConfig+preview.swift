//
//  ProductConfig+preview.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

import SwiftUI

extension ProductConfig {
    
    static let preview: Self = .init(
        balance: .init(
            textFont: .headline,
            textColor: .blue
        ),
        name: .init(
            textFont: .headline,
            textColor: .blue
        ),
        number: .init(
            textFont: .footnote,
            textColor: .orange
        ),
        title: .init(
            textFont: .caption,
            textColor: .green
        )
    )
}
