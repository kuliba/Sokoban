//
//  LandingImageBlock.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import Tagged

public extension Landing {
    
    struct ImageBlock: Equatable {
        
        public let withPlaceholder: WithPlaceholder
        public let backgroundColor: BackgroundColor
        public let link: Link
        
        public typealias WithPlaceholder = Tagged<_WithPlaceholder, Bool>
        public typealias BackgroundColor = Tagged<_BackgroundColor, String>
        public typealias Link = Tagged<_Link, String>

        public enum _WithPlaceholder {}
        public enum _BackgroundColor {}
        public enum _Link {}
    }
}

