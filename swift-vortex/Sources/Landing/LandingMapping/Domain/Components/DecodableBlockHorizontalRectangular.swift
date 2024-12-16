//
//  DecodableBlockHorizontalRectangular.swift
//
//
//  Created by Andryusina Nataly on 11.06.2024.
//

import Foundation

extension DecodableLanding.Data {
    
    struct BlockHorizontalRectangular: Decodable, Equatable  {
        
        let list: [Item]
        
        struct Item: Decodable, Equatable {
            
            let limitType: String
            let description: String?
            let title: String?
            
            let limits: [Limit]
            
            enum CodingKeys: String, CodingKey {
                case description, title, limitType
                case limits = "limit"
            }

            struct Limit: Decodable, Equatable {
                let id: String
                let title: String?
                let md5hash: String?
                let text: String?
                let maxSum: Decimal?
            }
        }
    }
}
