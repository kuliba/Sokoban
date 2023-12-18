//
//  ProductSelect+Product.swift
//  
//
//  Created by Igor Malyarov on 17.12.2023.
//

import Tagged

public extension ProductSelect {
    
    struct Product: Equatable, Identifiable {
        
        public let id: ID
        public let type: ProductType
        let header: String
        let title: String
        let number: String
        let amountFormatted: String
        let look: Look
        
        public init(
            id: ID,
            type: ProductType,
            header: String,
            title: String,
            footer: String,
            amountFormatted: String,
            look: Look
        ) {
            self.id = id
            self.type = type
            self.header = header
            self.title = title
            self.number = footer
            self.amountFormatted = amountFormatted
            self.look = look
        }
    }
}

public extension ProductSelect.Product {
    
    typealias ID = Tagged<_ID, Int>
    enum _ID {}
    
    struct Look: Equatable {
        
        let background: Icon
        let color: String
        let icon: Icon
        
        public init(
            background: Icon,
            color: String,
            icon: Icon
        ) {
            self.background = background
            self.color = color
            self.icon = icon
        }
    }
    
    enum ProductType: Equatable {
        
        case card, account
    }
}
