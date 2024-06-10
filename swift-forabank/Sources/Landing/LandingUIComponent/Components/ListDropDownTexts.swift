//
//  ListDropDownTexts.swift
//  
//
//  Created by Andryusina Nataly on 13.09.2023.
//

import Foundation
import Tagged

public extension UILanding.List {
    
    struct DropDownTexts: Equatable {
        
        public let id: UUID
        public let title: Title?
        public let list: [Item]
        
        public struct Item: Equatable {
            
            public let id: UUID
            public let title: String
            public let description: String
            
            public init(id: UUID = UUID(), title: String, description: String) {
                self.id = id
                self.title = title
                self.description = description
            }
            
            public typealias Title = Tagged<_Title, String>
            public typealias Description = Tagged<_Description, String>

            public enum _Title {}
            public enum _Description {}
        }
        
        public init(id: UUID = UUID(), title: Title?, list: [Item]) {
            self.id = id
            self.title = title
            self.list = list
        }
        
        public typealias Title = Tagged<_Title, String>

        public enum _Title {}
    }
}

extension UILanding.List.DropDownTexts {
    
    func imageRequests() -> [ImageRequest] {
        
        return []
    }
}
