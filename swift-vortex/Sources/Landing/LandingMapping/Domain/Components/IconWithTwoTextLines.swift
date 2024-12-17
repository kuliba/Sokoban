//
//  IconWithTwoTextLines.swift
//  
//
//  Created by Andryusina Nataly on 30.08.2023.
//

import Foundation

extension DecodableLanding.Data {
    
    struct IconWithTwoTextLines: Decodable, Equatable {
        
        let md5hash: String
        let title, subTitle: String?
    }
}
