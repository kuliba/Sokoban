//
//  NewProductButtonConfig.swift
//  ForaBank
//
//  Created by Disman Dmitry on 07.03.2024.
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
    
    static let sample: Self = .init(
        title: .init(
            textFont: Font.custom("Inter-Medium", size: 14.0),
            textColor: .textSecondary
        ),
        subtitle: .init(
            textFont: Font.custom("Inter-Medium", size: 14.0),
            textColor: .textPlaceholder
        )
    )
}
