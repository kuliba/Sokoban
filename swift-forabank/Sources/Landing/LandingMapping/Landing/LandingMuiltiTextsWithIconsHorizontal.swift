//
//  LandingMuiltiTextsWithIconsHorizontal.swift
//  
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import Foundation

extension Landing {
    
    public struct MuiltiTextsWithIconsHorizontal: Equatable {
        
        let md5hash, title: String
        
        public init(
            md5hash: String,
            title: String
        ) {
            self.md5hash = md5hash
            self.title = title
        }
    }
}
