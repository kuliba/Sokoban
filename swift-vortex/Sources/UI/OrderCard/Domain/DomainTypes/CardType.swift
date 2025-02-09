//
//  CardType.swift
//
//
//  Created by Igor Malyarov on 09.02.2025.
//

public struct CardType: Equatable {
    
    let icon: String
    let title: String
    
    public init(
        icon: String,
        title: String
    ) {
        self.title = title
        self.icon = icon
    }
}
