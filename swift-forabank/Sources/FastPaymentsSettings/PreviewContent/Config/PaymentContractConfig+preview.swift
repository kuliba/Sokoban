//
//  PaymentContractConfig+preview.swift
//
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI

extension PaymentContractConfig {
    
    static let preview: Self = .init(
        active: .init(
            title: .init(
                textFont: .headline, 
                textColor: .green
            ),
            toggleColor: .orange,
            subtitle: .init(
                textFont: .footnote,
                textColor: .orange
            )
        ),
        inactive: .init(
            title: .init(
                textFont: .footnote,
                textColor: .orange
            ),
            toggleColor: .red.opacity(0.4),
            subtitle: .init(
                textFont: .headline,
                textColor: .green.opacity(0.5)
            )
        )
    )
}
