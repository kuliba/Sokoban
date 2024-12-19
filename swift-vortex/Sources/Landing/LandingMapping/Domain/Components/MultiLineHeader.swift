//
//  MultiLineHeader.swift
//  
//
//  Created by Andryusina Nataly on 30.08.2023.
//

import Foundation

extension DecodableLanding.Data {
    
    struct MultiLineHeader: Decodable, Equatable {
        
        let backgroundColor: String
        let regularTextList, boldTextList: [String]?
    }
}
