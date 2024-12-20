//
//  ListDropDownTexts.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import Tagged

public extension CodableLanding.List {
    
    struct DropDownTexts: Equatable, Codable {
        
        public let title: Title?
        public let list: [Item]
        
        public struct Item: Equatable, Codable {
            
            public let title: String
            public let description: String
            
            public init(title: String, description: String) {
                self.title = title
                self.description = description
            }
            
            public typealias Title = Tagged<_Title, String>
            public typealias Description = Tagged<_Description, String>

            public enum _Title {}
            public enum _Description {}
        }
        
        public init(title: Title?, list: [Item]) {
            self.title = title
            self.list = list
        }
        
        public typealias Title = Tagged<_Title, String>

        public enum _Title {}
    }
}
