//
//  ButtonConfig+default.swift
//
//
//  Created by Igor Malyarov on 13.12.2023.
//

import SwiftUI

extension ButtonConfig {
    
    static let `default`: Self = .init(
        backgroundColor: .green,
        text: .init(
            textFont: .headline.weight(.black),
            textColor: .pink
        )
    )
}
