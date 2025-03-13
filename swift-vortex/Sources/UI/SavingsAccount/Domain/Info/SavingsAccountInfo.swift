//
//  SavingsAccountInfo.swift
//
//
//  Created by Andryusina Nataly on 13.03.2025.
//

import SwiftUI

public struct SavingsAccountInfo {
    
    public let list: [Item]
    public let title: String
    
    public init(
        list: [Item],
        title: String
    ) {
        self.list = list
        self.title = title
    }
    
    public struct Item {
        
        public let enable: Bool
        public let image: Image
        public let title: String
        
        public init(
            enable: Bool,
            image: Image,
            title: String
        ) {
            self.enable = enable
            self.image = image
            self.title = title
        }
    }
}
