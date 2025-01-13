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
            let detail: Detail?
            
            enum CodingKeys: String, CodingKey {
                case md5hash, title, subInfo
                case detail = "details"
            }
            
            struct Detail: Decodable, Equatable {
                let groupId: String
                let viewId: String
                
                enum CodingKeys: String, CodingKey {
                    case groupId = "detailsGroupId"
                    case viewId = "detailViewId"
                }
            }
        }
    }
}
