//
//  ImageBlock.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import Foundation

extension DecodableLanding.Data {
    
    struct ImageBlock: Decodable, Equatable {
        
        let withPlaceholder: Bool
        let backgroundColor, link: String
        
        enum CodingKeys: String, CodingKey {
            case backgroundColor
            case link = "imageLink"
            case withPlaceholder = "isPlaceholder"
        }
    }
}

