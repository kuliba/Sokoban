//
//  ImageBlockCodable.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import Tagged

public extension CodableLanding {
    
    struct ImageBlock: Equatable, Codable {
        
        public let withPlaceholder: WithPlaceholder
        public let backgroundColor: BackgroundColor
        public let link: Link
        
        public init(withPlaceholder: WithPlaceholder, backgroundColor: BackgroundColor, link: Link) {
            self.withPlaceholder = withPlaceholder
            self.backgroundColor = backgroundColor
            self.link = link
        }
        
        public typealias WithPlaceholder = Tagged<_WithPlaceholder, Bool>
        public typealias BackgroundColor = Tagged<_BackgroundColor, String>
        public typealias Link = Tagged<_Link, String>

        public enum _WithPlaceholder {}
        public enum _BackgroundColor {}
        public enum _Link {}
    }
}

