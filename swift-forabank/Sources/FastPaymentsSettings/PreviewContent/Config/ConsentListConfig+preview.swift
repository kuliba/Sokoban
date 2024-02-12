//
//  ConsentListConfig+preview.swift
//
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI

extension ConsentListConfig {
    
    static let preview: Self = .init(
        chevron: .preview,
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
