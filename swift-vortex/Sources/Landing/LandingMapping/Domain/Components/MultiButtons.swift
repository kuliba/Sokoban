//
//  MultiButtons.swift
//  
//
//  Created by Andryusina Nataly on 06.09.2023.
//

extension DecodableLanding.Data {
    
    struct MultiButtons: Decodable, Equatable {
        
        let list: [Item]
        
        struct Item: Decodable, Equatable {
            
            let text: String
            let style: String
            let detail: Detail?
            let link: String?
            let action: Action?
            
            enum CodingKeys: String, CodingKey {
                case detail = "details"
                case text = "buttonText"
                case style = "buttonStyle"
                case link, action
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
