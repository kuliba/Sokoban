//
//  MultiTextsWithIconsHorizontal.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import SwiftUI

public extension Landing {
    
    struct MultiTextsWithIconsHorizontal: Equatable {
        
        public let lists: [Item]
        
        public struct Item: Equatable, Identifiable {
            
            public let id = UUID()
            public let image: Image
            public let title: String?
            
            public init(
                image: Image,
                title: String?
            ) {
                self.image = image
                self.title = title
            }
        }
        
        public init(lists: [Item]) {
            
            self.lists = lists
        }
    }
}
