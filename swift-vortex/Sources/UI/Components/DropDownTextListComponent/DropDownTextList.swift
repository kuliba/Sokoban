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
    
    public struct Item: Equatable {
        
        public let title: String
        public let subTitle: String
        
        public init(title: String, subTitle: String) {
            self.title = title
            self.subTitle = subTitle
        }
    }
}
