//
//  ListHorizontalRoundImage.swift
//  
//
//  Created by Andryusina Nataly on 30.08.2023.
//

import Foundation

extension DecodableLanding.Data {
    
    struct ListHorizontalRoundImage: Decodable, Equatable {
        
        let title: String
        let list: [ListItem]?
        
        struct ListItem: Decodable, Equatable {
            
            let md5hash: String
            let title, subInfo: String?
            let details: Details
        }
        
        struct Details: Decodable, Equatable {
            
            let detailsGroupId, detailViewId: String
        }
    }
}
