//
//  ListVerticalRoundImage.swift
//  
//
//  Created by Andryusina Nataly on 05.09.2023.
//

import Foundation

extension DecodableLanding.Data {
    
    struct ListVerticalRoundImage: Decodable, Equatable {
        
        let title: String?
        let displayedCount: Double?
        let dropButtonOpenTitle, dropButtonCloseTitle: String?
        
        let list: [ListItem?]
        
        struct ListItem: Decodable, Equatable {
            
            let md5hash: String
            let title, subInfo: String?
            let link, appStore, googlePlay: String?
            let detail: Detail?
            let action: Action?
                        
            enum CodingKeys: String, CodingKey {
                case md5hash, title, link, appStore, googlePlay, action
                case detail = "details"
                case subInfo = "subTitle"
            }
            
            struct Detail: Decodable, Equatable {
                let groupId: String
                let viewId: String
                
                enum CodingKeys: String, CodingKey {
                    case groupId = "detailsGroupId"
                    case viewId = "detailViewId"
                }
            }
            
            struct Action: Decodable, Equatable {
                let type: String
                
                enum CodingKeys: String, CodingKey {
                    case type = "actionType"
                }
            }
        }
    }
}
