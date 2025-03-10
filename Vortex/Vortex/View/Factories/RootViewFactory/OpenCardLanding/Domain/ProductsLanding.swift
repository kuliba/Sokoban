//
//  ProductsLanding.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 10.03.2025.
//

import SharedConfigs
import Foundation

struct ProductsLanding {
    
    let title: TitleConfig
    let items: [Item]
    let imageUrl: URL
    let terms: URL
    let action: Action
    
    struct Action {
        
        let type: String
        let target: String
        let fallbackUrl: URL
    }
    
    struct Item {
        
        let bullet: Bool
        let title: String
    }
}
