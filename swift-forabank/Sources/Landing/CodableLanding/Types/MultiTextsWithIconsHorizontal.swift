//
//  MultiTextsWithIconsHorizontal.swift
//  
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import Foundation

extension CodableLanding.Multi {
    
    public struct TextsWithIconsHorizontal: Equatable, Codable {
        
        public let list: [Item]
        
        public struct Item: Equatable, Codable {
            
            public let md5hash, title: String
            
            public init(
                md5hash: String,
                title: String
            ) {
                self.md5hash = md5hash
                self.title = title
            }
        }
        
        public init(list: [Item]) {
            self.list = list
        }
    }
}
