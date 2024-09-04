//
//  LatestPlaceholderConfig+preview.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import PayHubUI

extension LatestPlaceholderConfig {
    
    static let preview: Self = .init(
        label: .init(
            circleSize: 56,
            frame: .init(width: 80, height: 96),
            spacing: 8
        ),
        textHeight: 8,
        textSpacing: 4,
        textWidth: 48
    )
}
