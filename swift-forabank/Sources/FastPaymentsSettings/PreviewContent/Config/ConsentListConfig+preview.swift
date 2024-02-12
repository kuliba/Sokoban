//
//  ConsentListConfig+preview.swift
//
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI

extension ConsentListConfig {
    
    static let preview: Self = .init(
        chevron: .init(
            image: .init(systemName: "chevron.down"), 
            color: .pink.opacity(0.5),
            title: .init(
                textFont: .footnote,
                textColor: .pink.opacity(0.5)
            )
        ),
        errorIcon: .init(
            backgroundColor: .pink.opacity(0.1),
            image: .init(systemName: "magnifyingglass")
        ),
        title: .init(
            textFont: .headline,
            textColor: .blue
        )
    )
}
