//
//  TextsWithIconsHorizontal.swift
//  
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import Foundation

extension Landing.DataView.Multi {
    
    public struct TextsWithIconsHorizontal: Equatable {
        
        public let list: [Item]
        
        public struct Item: Equatable {
            
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
