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
        collapsedBankList: .init(
            textFont: .headline,
            textColor: .green
        ),
        errorIcon: .init(
            backgroundColor: .pink.opacity(0.1),
            image: .init(systemName: "magnifyingglass")
        ),
        expandedConsent: .preview,
        image: .init(systemName: "building.columns"),
        title: .init(
            textFont: .headline,
            textColor: .blue
        )
    )
}
