//
//  Items.swift
//
//
//  Created by Дмитрий Савушкин on 21.02.2025.
//

import Foundation

public struct Items: Equatable {
    
    public let title: String?
    public let list: [Item]
    
    public init(title: String?, list: [Item]) {
        self.title = title
        self.list = list
    }
    
    public struct Item: Equatable, Identifiable {
        
        public let id: UUID
        public let md5hash: String
        public let title: String
        public let subtitle: String?
        
        public init(
            id: UUID = .init(),
            md5hash: String,
            title: String,
            subtitle: String?
        ) {
            self.id = id
            self.md5hash = md5hash
            self.title = title
            self.subtitle = subtitle
        }
    }
}
