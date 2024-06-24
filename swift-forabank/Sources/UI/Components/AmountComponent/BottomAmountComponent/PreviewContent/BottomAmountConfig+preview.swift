//
//  BottomAmountConfig+preview.swift
//
//
//  Created by Igor Malyarov on 20.06.2024.
//

import SharedConfigs

extension BottomAmountConfig {
    
    static let preview: Self = .init(
        amount: .init(
            textFont: .title.bold(),
            textColor: .orange
        ),
        backgroundColor: .black.opacity(0.8),
        button: .preview,
        buttonSize: .init(width: 114, height: 40),
        dividerColor: .white,
        title: "Сумма платежа",
        titleConfig: .init(
            textFont: .caption,
            textColor: .pink
        )
    )
}

extension ButtonConfig {
    
    static let preview: Self = .init(
        active: .active,
        inactive: .inactive
    )
}

extension ButtonStateConfig {
    
    static let active: Self = .init(
        backgroundColor: .green,
        text: .init(
            textFont: .headline.weight(.black),
            textColor: .white
        )
    )
    
    static let inactive: Self = .init(
        backgroundColor: .orange.opacity(0.3),
        text: .init(
            textFont: .headline.weight(.light),
            textColor: .black.opacity(0.7)
        )
    )
}
