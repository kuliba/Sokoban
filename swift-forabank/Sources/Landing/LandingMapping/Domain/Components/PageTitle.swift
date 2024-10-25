//
//  PageTitle.swift
//  
//
//  Created by Andryusina Nataly on 29.08.2023.
//

import Foundation

extension DecodableLanding.Data {
    
    struct PageTitle: Decodable, Equatable {
        
        let title: String
        let subTitle: String?

        let transparency: Bool
        
        
        private enum CodingKeys : String, CodingKey {
            case title, transparency
            case subTitle = "subtitle"
        }
    }
}

