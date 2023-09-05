//
//  ListHorizontalRectangleImage.swift
//  
//
//  Created by Andryusina Nataly on 05.09.2023.
//

import Foundation

extension DecodableLanding.Data {
    
    struct ListHorizontalRectangleImage: Decodable, Equatable {
        
        let list: [Item]
        
        struct Item: Decodable, Equatable {
            
            let imageLink: String
            let link: String
            let detail: Detail?
            
            enum CodingKeys: String, CodingKey {
                case imageLink, link
                case detail = "details"
            }

            struct Detail: Decodable, Equatable {
                let detailsGroupId: String
                let detailViewId: String
            }
        }
    }
}
