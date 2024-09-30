//
//  VerticalSpacing.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import Tagged

public extension CodableLanding {
    
    struct VerticalSpacing: Equatable, Codable {
        
        public let backgroundColor: BackgroundColor
        public let type: Kind
        
        public init(backgroundColor: BackgroundColor, type: Kind) {
            self.backgroundColor = backgroundColor
            self.type = type
        }
        
        public typealias BackgroundColor = Tagged<_BackgroundColor, String>
        public typealias Kind = Tagged<_Kind, String>

        public enum _BackgroundColor {}
        public enum _Kind {}
    }
}
