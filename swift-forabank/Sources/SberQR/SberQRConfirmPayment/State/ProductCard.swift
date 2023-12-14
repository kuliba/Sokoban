//
//  ProductCard.swift
//
//
//  Created by Igor Malyarov on 14.12.2023.
//

import SwiftUI

public struct ProductCard: Equatable {
    
    let data: CardData
    let look: Look
    
    public init(
        data: CardData,
        look: Look
    ) {
        self.data = data
        self.look = look
    }
}

extension ProductCard {
    
    init(product: ProductSelect.Product) {
        
        self.init(
            data: .init(
                balanceFormatted: product.amountFormatted,
                number: product.number,
                title: product.title
            ),
            look: .init(
                background: product.look.background,
                backgroundColor: Color(product.look.color),
                cardIcon: product.look.icon,
                mainCardMark: .svg("")
            )
        )
    }
}

public extension ProductCard {
    
    struct CardData: Equatable {
        
        let balanceFormatted: String
        let number: String
        let title: String
        
        public init(
            balanceFormatted: String,
            number: String,
            title: String
        ) {
            self.balanceFormatted = balanceFormatted
            self.number = number
            self.title = title
        }
    }
    
    struct Look: Equatable {
        
        let background: Icon
        let backgroundColor: Color
        let cardIcon: Icon
        let mainCardMark: Icon
        
        public init(
            background: Icon,
            backgroundColor: Color,
            cardIcon: Icon,
            mainCardMark: Icon
        ) {
            self.background = background
            self.backgroundColor = backgroundColor
            self.cardIcon = cardIcon
            self.mainCardMark = mainCardMark
        }
    }
}
