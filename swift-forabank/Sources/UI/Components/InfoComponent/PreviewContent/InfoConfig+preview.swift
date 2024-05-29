//
//  InfoConfig+preview.swift
//
//
//  Created by Igor Malyarov on 12.12.2023.
//

import SwiftUI

public extension InfoConfig {
    
    static let preview: Self = .init(
        title: .init(
            textFont: .caption,
            textColor: .secondary
        ),
        value: .init(
            textFont: .subheadline,
            textColor: .primary
        )
    )
}
