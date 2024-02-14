//
//  ExpandedConsentConfig+ext.swift
//  
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI

extension ExpandedConsentConfig {
    
    static let preview: Self = .init(
        apply: .init(
            backgroundColor: .pink, //background: #F8F8F8D1; 82%
            title: .init(
                textFont: .title3,
                textColor: .white
            )
        ),
        bank: .init(
            textFont: .headline,
            textColor: .green
        ),
        checkmark: .preview,
        noMatch: .init(
            image: .init(
                backgroundColor: .blue.opacity(0.7),
                image: .init(systemName: "magnifyingglass")
            ),
            title: .init(
                textFont: .footnote, 
                textColor: .orange
            )
        )
    )
}
