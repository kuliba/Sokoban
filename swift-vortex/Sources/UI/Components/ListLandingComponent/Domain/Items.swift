//
//  Items.swift
//
//
//  Created by Дмитрий Савушкин on 21.02.2025.
//

import Foundation

public struct Items: Equatable {
    
    let title: String?
    let list: [Item]
    
    public init(title: String?, list: [Item]) {
        self.title = title
        self.list = list
    }
    
    public struct Item: Equatable, Identifiable {
        
        public let id: UUID
        let md5hash: String
        let title: String
        let subtitle: String?
        
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
