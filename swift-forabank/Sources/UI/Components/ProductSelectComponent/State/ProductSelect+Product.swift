//
//  ProductSelect+Product.swift
//  
//
//  Created by Igor Malyarov on 17.12.2023.
//

import Foundation
import Tagged
import UIPrimitives
import SwiftUI

public extension ProductSelect {
    
    struct Product: Equatable, Identifiable {
        
        public let id: ID
        public let type: ProductType
        public let isAdditional: Bool
        let header: String
        let title: String
        let number: String
        let amountFormatted: String
        public let balance: Decimal
        let look: Look
        
        public init(
            id: ID,
            type: ProductType,
            isAdditional: Bool,
            header: String,
            title: String,
            footer: String,
            amountFormatted: String,
            balance: Decimal,
            look: Look
        ) {
            self.id = id
            self.type = type
            self.isAdditional = isAdditional
            self.header = header
            self.title = title
            self.number = footer
            self.amountFormatted = amountFormatted
            self.balance = balance
            self.look = look
        }
    }
}

public extension ProductSelect.Product {
    
    typealias ID = Tagged<_ID, Int>
    enum _ID {}
    
    struct Look: Equatable {
        
        let background: Icon
        let color: Color
        let icon: Icon
        
        public init(
            background: Icon,
            color: Color,
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
