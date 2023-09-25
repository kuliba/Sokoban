//
//  IconWithTwoTextLinesCodable.swift
//  
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import Foundation

extension CodableLanding {
    
    public struct IconWithTwoTextLines: Equatable, Codable {
        
        public let md5hash: String
        public let title, subTitle: String?
        
        public init(
            md5hash: String,
            title: String?,
            subTitle: String?
        ) {
            
            self.md5hash = md5hash
            self.title = title
            self.subTitle = subTitle
        }
    }
}
