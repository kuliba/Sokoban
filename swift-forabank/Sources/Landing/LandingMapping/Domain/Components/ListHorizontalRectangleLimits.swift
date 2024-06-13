//
//  ListHorizontalRectangleLimits.swift
//
//
//  Created by Andryusina Nataly on 07.06.2024.
//

import Foundation

extension DecodableLanding.Data {
    
    struct ListHorizontalRectangleLimits: Decodable, Equatable {
        
        let list: [Item]
        
        struct Item: Decodable, Equatable {
            
            let action: Action
            let limitType: String
            let md5hash: String
            let title: String
            
            let limits: [Limit]
            
            enum CodingKeys: String, CodingKey {
                case md5hash, title, limitType, action
                case limits = "limit"
            }

            struct Limit: Decodable, Equatable {
                let id: String
                let title: String
                let colorHEX: String
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
