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
            
            init(from decoder: any Decoder) throws {
                
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                self.imageLink = try container.decodeWrapper(String.self, forKey: Item.CodingKeys.imageLink, defaultValue: "")
                self.link = try container.decodeWrapper(String.self, forKey: Item.CodingKeys.link, defaultValue: "")
                self.detail = try container.decodeIfPresent(Item.Detail.self, forKey: Item.CodingKeys.detail) ?? nil
            }
            
            struct Detail: Decodable, Equatable {
                let groupId: String
                let viewId: String?
                
                enum CodingKeys: String, CodingKey {
                    case groupId = "detailsGroupId"
                    case viewId = "detailViewId"
                }
                
                init(from decoder: any Decoder) throws {
                    
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    
                    self.groupId = try container.decodeWrapper(String.self, forKey: Detail.CodingKeys.groupId, defaultValue: "")
                    self.viewId = try? container.decodeIfPresent(String.self, forKey: Detail.CodingKeys.viewId)
                }
            }
        }
    }
}
