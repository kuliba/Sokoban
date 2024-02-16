//
//  AccountLinkingConfig+preview.swift
//
//
//  Created by Igor Malyarov on 12.02.2024.
//

extension AccountLinkingConfig {
    
    static let preview: Self = .init(
        image: .init(systemName: "slider.horizontal.2.square"),
        title: .init(
            textFont: .caption,
            textColor: .orange
        )
    )
}
