//
//  BankDefaultConfig+preview.swift
//
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI

extension BankDefaultConfig {
    
    static let preview: Self = .init(
        logo: .init(
            backgroundColor: .pink.opacity(0.5),
            image: .init(systemName: "building.columns")
        ),
        title: .init(
            textFont: .title3,
            textColor: .orange
        ),
        toggleConfig: .init(
            onDisabled: .init(
                toggleColor: .orange.opacity(0.7)
            ),
            offEnabled: .init(
                toggleColor: .blue
            ),
            offDisabled: .init(
                toggleColor: .blue.opacity(0.5)
            )
        ),
        subtitle: .init(
            textFont: .headline,
            textColor: .blue
        )
    )
}
