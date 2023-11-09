//
//  Input.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 24.10.2023.
//

import Foundation

public extension Operation.Parameter {
    
    struct Input: Hashable {
        
        let value: String
        let title: String
        let icon: String
        
        public init(
            value: String,
            title: String,
            icon: String
        ) {
            self.value = value
            self.title = title
            self.icon = icon
        }
    }
}
