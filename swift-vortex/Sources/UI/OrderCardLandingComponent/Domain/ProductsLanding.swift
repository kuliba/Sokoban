//
//  ProductsLanding.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 10.03.2025.
//

import SharedConfigs
import Foundation

struct Product {
    
    let title: String
    let items: [Item]
    let imageURL: String
    let terms: URL
    let action: Action
    
    struct Action {
        
        let type: String
        let target: String
        let fallbackURL: URL
    }
    
    struct Item {
        
        let bullet: Bool
        let title: String
    }
}
