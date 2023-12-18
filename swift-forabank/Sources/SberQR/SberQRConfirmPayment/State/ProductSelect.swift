//
//  ProductSelect.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import Foundation
import Tagged

public enum ProductSelect: Equatable {
    
    case compact(Product)
    case expanded(Product, [Product])
}

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
}

public extension ProductSelect.Product {
    
    typealias ID = Tagged<_ID, Int>
    enum _ID {}
    
    enum ProductType: Equatable {
        
        case card, account
    }
}
