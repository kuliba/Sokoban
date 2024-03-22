//
//  NewProductButtonConfig.swift
//  CarouselPreview
//
//  Created by Andryusina Nataly on 22.03.2024.
//

import SwiftUI
import UIPrimitives

public struct NewProductButtonConfig {
    
    let title: TextConfig
    let subtitle: TextConfig
    
    public init(
        title: TextConfig,
        subtitle: TextConfig
    ) {
        self.title = title
        self.subtitle = subtitle
    }
}

public extension NewProductButtonConfig {
    
    static let preview: Self = .init(
        title: .init(
            textFont: .footnote,
            textColor: Color(red: 0.11, green: 0.11, blue: 0.11)
        ),
        subtitle: .init(
            textFont: .footnote,
            textColor: Color(red: 0.6, green: 0.6, blue: 0.6)
        )
    )
}
