//
//  ProductsLanding.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 10.03.2025.
//

import Foundation

public struct Product {
    
    public let action: Action
    public let imageURL: String
    public let items: [Item]
    public let terms: String
    public let title: String
    
    public init(
        action: Action,
        imageURL: String,
        items: [Item],
        terms: String,
        title: String
    ) {
        self.action = action
        self.imageURL = imageURL
        self.items = items
        self.terms = terms
        self.title = title
    }
    
    public struct Action {
        
        public let fallbackURL: String?
        public let target: String
        public let type: String
        
        public init(
            fallbackURL: String?,
            target: String,
            type: String
        ) {
            self.fallbackURL = fallbackURL
            self.target = target
            self.type = type
        }
    }
    
    public struct Item {
        
        public let bullet: Bool
        public let title: String
        
        public init(
            bullet: Bool,
            title: String
        ) {
            self.bullet = bullet
            self.title = title
        }
    }
}
