//
//  SliderConfig+ext.swift
//
//
//  Created by Andryusina Nataly on 19.02.2024.
//

import SwiftUI

public extension SliderConfig {
    
    static let `default`: Self = .init(
        colors: .init(
            backgroundColor: Color.black.opacity(0.1),
            foregroundColor: .white,
            thumbIconColor: .gray),
        items: .init(
            notActivated: .notActivated,
            confirmingActivation: .confirmingActivation,
            activating: .activating,
            activated: .activated),
        sizes: .init(),
        font: .subheadline)
}

