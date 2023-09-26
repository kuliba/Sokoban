//
//  LandingTextsWithIconHorizontal.swift
//  
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import Foundation

extension Landing {
    
    public struct TextsWithIconHorizontal: Equatable {
        
        public let md5hash, title: String
        public let contentCenterAndPull: Bool
        
        public init(
            md5hash: String,
            title: String,
            contentCenterAndPull: Bool
        ) {
            self.md5hash = md5hash
            self.title = title
            self.contentCenterAndPull = contentCenterAndPull
        }
    }
}
