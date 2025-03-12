//
//  ProductsLanding.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 10.03.2025.
//

import Foundation

public struct Product {
    
    let action: Action
    let imageURL: String
    let items: [Item]
    let terms: String
    let title: String
    
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
        
        let fallbackURL: String?
        let target: String
        let type: String
        
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
        
        let bullet: Bool
        let title: String
        
        public init(
            bullet: Bool,
            title: String
        ) {
            self.bullet = bullet
            self.title = title
        }
    }
}
