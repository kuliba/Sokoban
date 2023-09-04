//
//  TextsWithIconHorizontal.swift
//  
//
//  Created by Andryusina Nataly on 30.08.2023.
//

import Foundation

extension DecodableLanding.Data {
    
    struct TextsWithIconHorizontal: Decodable, Equatable {
        
        let md5hash, title: String
        let contentCenterAndPull: Bool
    }
}
