//
//  AmountConfig+default.swift
//
//
//  Created by Igor Malyarov on 13.12.2023.
//

import PrimitiveComponents
import SwiftUI

public extension AmountConfig {
    
    static let `default`: Self = .init(
        amount: .init(
            textFont: .title.bold(),
            textColor: .white
        ),
        backgroundColor: .black.opacity(0.8),
        button: .default,
        dividerColor: .white.opacity(0.8),
        title: .init(
            textFont: .caption,
            textColor: .gray
        )
    )
}
