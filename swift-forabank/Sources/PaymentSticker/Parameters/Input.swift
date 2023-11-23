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
        public let warning: String?
        
        public init(
            value: String,
            title: String,
            warning: String?
        ) {
            self.value = value
            self.title = title
            self.warning = warning
        }
    }
}
