//
//  Messages.swift
//
//
//  Created by Igor Malyarov on 09.02.2025.
//

public struct Messages: Equatable {
    
    let description: String
    let icon: String
    let subtitle: String
    let title: String
    public var isOn: Bool
    
    public init(
        description: String,
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
