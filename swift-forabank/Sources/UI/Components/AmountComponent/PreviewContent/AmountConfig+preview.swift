//
//  AmountConfig+preview.swift
//
//
//  Created by Igor Malyarov on 13.12.2023.
//

import ButtonComponent
import SharedConfigs
import SwiftUI

public extension AmountConfig {
    
    static let preview: Self = .init(
        amount: .init(
            textFont: .title.bold(),
            textColor: .white
        ),
        backgroundColor: .black.opacity(0.8),
        button: .preview,
        dividerColor: .white.opacity(0.8),
        title: .init(
            textFont: .caption,
            textColor: .gray
        )
    )
}
