//
//  Config+default.swift
//  
//
//  Created by Igor Malyarov on 12.12.2023.
//

import SwiftUI

extension Config {
    
    static let `default`: Self = .init(
        background: .default,
        productSelectViewConfig: .default
    )
}

extension Config.Background {
    
    static let `default`: Self = .init(
        color: .gray.opacity(0.2)
    )
}

extension Config.ProductSelectViewConfig {
    
    static let `default`: Self = .init(
        amount: .init(
            textFont: .body,
            textColor: .purple
        ),
        footer: .init(
            textFont: .caption,
            textColor: .gray.opacity(0.5)
        ),
        header: .init(
            textFont: .footnote,
            textColor: .pink.opacity(0.5)
        ),
        title: .init(
            textFont: .headline,
            textColor: .green
        )
    )
}
