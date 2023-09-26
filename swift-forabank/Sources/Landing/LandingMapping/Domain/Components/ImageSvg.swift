//
//  ImageSvg.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import Foundation

extension DecodableLanding.Data {
    
    struct ImageSvg: Decodable, Equatable {
        
        let backgroundColor, md5hash: String
    }
}
