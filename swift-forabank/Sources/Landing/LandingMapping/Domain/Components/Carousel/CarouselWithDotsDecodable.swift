//
//  CarouselWithDotsDecodable.swift
//
//
//  Created by Andryusina Nataly on 30.09.2024.
//

extension DecodableLanding.Data {
    
    struct CarouselWithDotsDecodable: Decodable, Equatable {
        
        let title: String?
        let size, scale: String
        let loopedScrolling: Bool
        
        let list: [ListItem]
        
        struct ListItem: Decodable, Equatable {
            
            let imageLink: String
            let link: String?
            let action: Action?
                        
            struct Action: Decodable, Equatable {
                
                let type: String
                let target: String?
                
                enum CodingKeys: String, CodingKey {
                    case type = "actionType"
                    case target
                }
            }
        }
    }
}
