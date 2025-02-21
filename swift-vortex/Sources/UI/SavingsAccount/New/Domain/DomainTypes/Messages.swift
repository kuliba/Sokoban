//
//  Messages.swift
//
//
//  Created by Andryusina Nataly on 20.02.2025.
//

import Foundation

public struct Messages: Equatable {
    
    let description: AttributedString
    let icon: String
    let subtitle: String
    let title: String
    public var isOn: Bool
    
    public init(
        description: AttributedString,
        icon: String,
        subtitle: String,
        title: String,
        isOn: Bool
    ) {
        self.description = description
        self.icon = icon
        self.subtitle = subtitle
        self.title = title
        self.isOn = isOn
    }
}
