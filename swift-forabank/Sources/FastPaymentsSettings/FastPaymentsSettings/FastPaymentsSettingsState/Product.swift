//
//  Product.swift
//
//
//  Created by Igor Malyarov on 16.01.2024.
//

import Foundation
import Tagged
import SwiftUI

public struct Product: Equatable, Identifiable {
    
    public let id: ID
    public let header: String
    public let title: String
    public let number: String
    public let amountFormatted: String
    public let balance: Decimal
    public let look: Look
    
    public init(
        id: ID,
        header: String,
        title: String,
        number: String,
        amountFormatted: String,
        balance: Decimal,
        look: Look
    ) {
        self.id = id
        self.header = header
        self.title = title
        self.number = number
        self.amountFormatted = amountFormatted
        self.balance = balance
        self.look = look
    }
}

public extension Product {
    
    typealias ID = ProductID<AccountID, CardID>
    
    typealias AccountID = Tagged<_AccountID, Int>
    enum _AccountID {}
    
    typealias CardID = Tagged<_CardID, Int>
    enum _CardID {}
}

public extension Product {
    
    struct Look: Equatable {
        
        public let background: Icon
        public let color: String
        public let icon: Icon
        
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
        case image(Image)
    }
}
