//
//  MultiMarkersText.swift
//  
//
//  Created by Andryusina Nataly on 05.09.2023.
//

import Foundation

extension DecodableLanding.Data {
    
    struct MultiMarkersText: Decodable, Equatable {
        
        let backgroundColor, style: String
        let list: [String]?
    }
}
