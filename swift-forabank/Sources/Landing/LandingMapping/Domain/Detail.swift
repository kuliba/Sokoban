//
//  Detail.swift
//  
//
//  Created by Andryusina Nataly on 30.08.2023.
//

import Foundation

extension DecodableLanding.Data {
    
    struct Detail: Decodable, Equatable {
        
        let groupId: String
        let dataGroup: [DataGroup]
        
        enum CodingKeys: String, CodingKey {
            case groupId = "detailsGroupId"
            case dataGroup
        }

        struct DataGroup: Decodable, Equatable {
            
            let viewId: String
            let dataView: [DataView]
            
            enum CodingKeys: String, CodingKey {
                case viewId = "detailViewId"
                case dataView
            }
        }
    }
}
