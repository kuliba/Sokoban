//
//  Item.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

public struct Item<ItemType, Icon>: Identifiable {
    
    public var id: String
    public let title: String
    public let subtitle: String?
    public let icon: Icon
    
    public init(
        id: String,
        title: String,
        subtitle: String?,
        icon: Icon
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }
}

extension Item: Equatable where ItemType: Equatable, Icon: Equatable {}
