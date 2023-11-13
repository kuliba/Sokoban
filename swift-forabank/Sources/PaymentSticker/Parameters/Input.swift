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
        
        public init(
            value: String,
            title: String
        ) {
            self.value = value
            self.title = title
        }
    }
}

extension Operation.Parameter.Input {
    
    public func hash(into hasher: inout Hasher) {
        
        hasher.combine(title)
        hasher.combine(value)
    }
    
    public static func == (
        lhs: Operation.Parameter.Input,
        rhs: Operation.Parameter.Input
    ) -> Bool {
        lhs.title == rhs.title && lhs.value == rhs.value
    }
}
