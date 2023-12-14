//
//  InfoConfig+default.swift
//
//
//  Created by Igor Malyarov on 12.12.2023.
//

import SwiftUI

extension InfoConfig {
    
    static let `default`: Self = .init(
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
