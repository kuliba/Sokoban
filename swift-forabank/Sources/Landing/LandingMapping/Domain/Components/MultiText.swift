//
//  MultiText.swift
//  
//
//  Created by Andryusina Nataly on 05.09.2023.
//

import Tagged

extension DecodableLanding.Data {
    
    struct MultiText: Decodable, Equatable {
        
        let list: [String?]
    }
}
