//
//  AmountConfig+default.swift
//
//
//  Created by Igor Malyarov on 13.12.2023.
//

import SwiftUI

extension AmountConfig {
    
    static let `default`: Self = .init(
        amount: .init(
            textFont: .title.bold(),
            textColor: .white
        ),
        backgroundColor: .black.opacity(0.8),
        button: .init(
            textFont: .headline.bold(),
            textColor: .white
        ),
        buttonColor: .pink,
        dividerColor: .white.opacity(0.8),
        title: .init(
            textFont: .caption,
            textColor: .gray
        )
    )
}
