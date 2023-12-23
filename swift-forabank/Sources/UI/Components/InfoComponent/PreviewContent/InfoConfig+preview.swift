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
            textFont: .subheadline,
            textColor: .secondary
        ),
        value: .init(
            textFont: .headline,
            textColor: .primary
        )
    )
}
