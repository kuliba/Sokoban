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
        let icon: Icon
        let title: String
        let number: String
        let amountFormatted: String
        let color: String
        
        public init(
            id: ID,
            type: ProductType,
            header: String,
            icon: Icon,
            title: String,
            footer: String,
            amountFormatted: String,
            color: String
        ) {
            self.id = id
            self.type = type
            self.header = header
            self.icon = icon
            self.title = title
            self.number = footer
            self.amountFormatted = amountFormatted
            self.color = color
        }
    }
}

public extension ProductSelect.Product {
    
    typealias ID = Tagged<_ID, Int>
    enum _ID {}
    
    enum ProductType {
        
        case card, account
    }
}
