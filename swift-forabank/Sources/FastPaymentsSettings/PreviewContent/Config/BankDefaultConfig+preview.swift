//
//  BankDefaultConfig+preview.swift
//
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI

extension BankDefaultConfig {
    
    static let preview: Self = .init(
        onDisabled: .init(
            toggleColor: .orange.opacity(0.7)
        ),
        offEnabled: .init(
            toggleColor: .blue
        ),
        offDisabled: .init(
            toggleColor: .blue.opacity(0.5)
        )
    )
}
