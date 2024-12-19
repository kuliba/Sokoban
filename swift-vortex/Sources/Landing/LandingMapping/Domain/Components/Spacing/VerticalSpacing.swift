//
//  VerticalSpacing.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import Foundation

extension DecodableLanding.Data {
    
    struct VerticalSpacing: Decodable, Equatable {
        
        let backgroundColor, type: String
        
        enum CodingKeys: String, CodingKey {
            case backgroundColor
            case type = "spacingType"
        }
    }
}
