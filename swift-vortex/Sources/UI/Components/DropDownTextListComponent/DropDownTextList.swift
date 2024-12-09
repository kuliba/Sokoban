//
//  DropDownTextList.swift
//
//
//  Created by Valentin Ozerov on 06.12.2024.
//

import Foundation

public struct DropDownTextList {
    
    public let title: String?
    public let items: [Item]
    
    public init(title: String?, items: [Item]) {
        self.title = title
        self.items = items
    }
    
    public struct Item: Equatable, Identifiable {
        
        public let id: UUID
        public let title: String
        public let subTitle: String
        
        public init(id: UUID = .init(), title: String, subTitle: String) {
            self.id = id
            self.title = title
            self.subTitle = subTitle
        }
    }
}
