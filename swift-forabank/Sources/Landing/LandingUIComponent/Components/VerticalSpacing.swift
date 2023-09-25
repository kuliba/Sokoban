//
//  VerticalSpacing.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import Foundation

import SwiftUI

public extension UILanding {
    
    struct VerticalSpacing: Hashable, Identifiable  {
        
        public let id = UUID()
        public let backgroundColor: BackgroundColorType
        public let spacingType: SpacingType

        public enum SpacingType: String, Hashable {
            
            case small = "SMALL"
            case big = "BIG"
            case negativeOffset = "negativeOffset"
        }
        
        public init(backgroundColor: BackgroundColorType, spacingType: SpacingType) {
            self.backgroundColor = backgroundColor
            self.spacingType = spacingType
        }
    }
}

extension UILanding.VerticalSpacing {
    
    func imageRequests() -> [ImageRequest] {
        
        return []
    }
}
