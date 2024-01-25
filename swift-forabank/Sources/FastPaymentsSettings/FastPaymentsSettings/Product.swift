//
//  Product.swift
//
//
//  Created by Igor Malyarov on 16.01.2024.
//

import Foundation
import Tagged

public struct Product: Equatable, Identifiable {
    
    public let id: ID
    public let type: ProductType
    public let header: String
    public let title: String
    public let number: String
    public let amountFormatted: String
    public let balance: Decimal
    public let look: Look
    
    public init(
        id: ID,
        type: ProductType,
        header: String,
        title: String,
        number: String,
        amountFormatted: String,
        balance: Decimal,
        look: Look
    ) {
        self.id = id
        self.type = type
        self.header = header
        self.title = title
        self.number = number
        self.amountFormatted = amountFormatted
        self.balance = balance
        self.look = look
    }
}

public extension Product {
    
    typealias ID = Tagged<_ID, Int>
    enum _ID {}
    
    enum ProductType: Equatable {
        
        case card, account
    }
    
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

public extension Product.Look {
    
    enum Icon: Equatable {
        
        case svg(String)
    }
}
