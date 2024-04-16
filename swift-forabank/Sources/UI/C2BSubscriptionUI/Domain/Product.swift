//
//  Product.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

import Tagged
import UIPrimitives

public struct Product: Equatable {
    
    public let id: ID
    public let title: String
    public let name: String
    public let number: String
    public let icon: Icon
    public let balance: String
    
    public init(
        id: ID,
        title: String,
        name: String,
        number: String,
        icon: Icon,
        balance: String
    ) {
        self.id = id
        self.title = title
        self.name = name
        self.number = number
        self.icon = icon
        self.balance = balance
    }
}

public extension Product {
    
    enum ID: Hashable {
        
        case account(AccountID)
        case card(CardID)
    }
}

public extension Product.ID {
    
    typealias AccountID = Tagged<_AccountID, Int>
    enum _AccountID {}
    
    typealias CardID = Tagged<_CardID, Int>
    enum _CardID {}
}
