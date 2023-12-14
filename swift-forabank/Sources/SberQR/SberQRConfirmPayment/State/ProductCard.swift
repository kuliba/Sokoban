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

public extension ProductCard {
    
    struct CardData: Equatable {
        
        let balanceFormatted: String
        let number: String
        let type: String
        
        public init(
            balanceFormatted: String,
            number: String,
            type: String
        ) {
            self.balanceFormatted = balanceFormatted
            self.number = number
            self.type = type
        }
    }
    
    struct Look: Equatable {
        
        let background: Icon
        let backgroundColor: Color
        let cardIcon: Icon
        let logo: Icon
        let mainCardMark: Icon
        let paymentSystemLogo: Icon
        
        public init(
            background: Icon,
            backgroundColor: Color,
            cardIcon: Icon,
            logo: Icon,
            mainCardMark: Icon,
            paymentSystemLogo: Icon
        ) {
            self.background = background
            self.backgroundColor = backgroundColor
            self.cardIcon = cardIcon
            self.logo = logo
            self.mainCardMark = mainCardMark
            self.paymentSystemLogo = paymentSystemLogo
        }
    }
}
