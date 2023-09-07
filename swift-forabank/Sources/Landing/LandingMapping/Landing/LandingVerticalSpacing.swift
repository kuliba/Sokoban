//
//  LandingVerticalSpacing.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import Tagged

public extension Landing {
    
    struct VerticalSpacing: Equatable {
        
        public let backgroundColor: BackgroundColor
        public let type: Kind
        
        public typealias BackgroundColor = Tagged<_BackgroundColor, String>
        public typealias Kind = Tagged<_Kind, String>

        public enum _BackgroundColor {}
        public enum _Kind {}
    }
}
