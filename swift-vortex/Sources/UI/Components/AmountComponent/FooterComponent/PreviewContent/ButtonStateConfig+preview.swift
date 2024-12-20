//
//  ButtonStateConfig+preview.swift
//
//
//  Created by Igor Malyarov on 22.06.2024.
//

import SharedConfigs

extension ButtonStateConfig {
    
    static let tapped: Self = .init(
        backgroundColor: .pink.opacity(0.3),
        text: .init(
            textFont: .headline.weight(.light),
            textColor: .black.opacity(0.7)
        )
    )
}
