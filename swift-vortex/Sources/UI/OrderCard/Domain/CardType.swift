//
//  CardType.swift
//
//
//  Created by Igor Malyarov on 09.02.2025.
//

public struct CardType: Equatable {
    
    let title: String
    let cardType: String
    let icon: String
    
    public init(
        title: String,
        cardType: String,
        icon: String
    ) {
        self.title = title
        self.cardType = cardType
        self.icon = icon
    }
}
