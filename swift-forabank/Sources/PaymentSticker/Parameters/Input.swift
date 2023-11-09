//
//  Input.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 24.10.2023.
//

import Foundation

public extension Operation.Parameter {
    
    struct Input: Hashable {
        
        public var value: String
        public let title: String
        public let icon: String
        
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

extension Operation.Parameter.Input {
    
    public func hash(into hasher: inout Hasher) {
        
        hasher.combine(title)
        hasher.combine(icon)
        hasher.combine(value)
    }
    
    public static func == (
        lhs: Operation.Parameter.Input,
        rhs: Operation.Parameter.Input
    ) -> Bool {
        lhs.icon == rhs.icon && lhs.title == rhs.title && lhs.value == rhs.value
    }
}
