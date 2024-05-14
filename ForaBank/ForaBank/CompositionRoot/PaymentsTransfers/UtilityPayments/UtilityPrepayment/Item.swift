//
//  Item.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

public struct Item<ItemType, Subtitle, Icon>: Identifiable {
    
    public var id: String
    public let title: String
    public let subtitle: Subtitle
    public let icon: Icon
    
    public init(
        id: String,
        title: String,
        subtitle: Subtitle,
        icon: Icon
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }
}

extension Item: Equatable where ItemType: Equatable, Subtitle: Equatable, Icon: Equatable {}
