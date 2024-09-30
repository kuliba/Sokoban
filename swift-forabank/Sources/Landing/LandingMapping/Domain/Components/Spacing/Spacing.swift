//
//  Spacing.swift
//  
//
//  Created by Andryusina Nataly on 30.09.2024.
//

import Foundation

extension DecodableLanding.Data {
    
    struct Spacing: Decodable, Equatable {
        
        let backgroundColor: String
        let sizeDp: CGFloat
    }
}
