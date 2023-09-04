//
//  Detail.swift
//  
//
//  Created by Andryusina Nataly on 30.08.2023.
//

import Foundation

extension DecodableLanding.Data {
    
    struct Detail: Decodable, Equatable {
        
        let detailsGroupId: String
        let dataGroup: [DataGroup]
        
        struct DataGroup: Decodable, Equatable {
            
            let detailViewId: String
            let dataView: [DataView]
        }
    }
}
