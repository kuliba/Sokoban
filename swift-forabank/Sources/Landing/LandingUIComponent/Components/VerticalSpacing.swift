//
//  VerticalSpacing.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import Foundation

import SwiftUI

public extension UILanding {
    
    struct VerticalSpacing: Equatable  {
        
        let id: UUID
        let backgroundColor: BackgroundColorType
        let spacingType: SpacingType

        public enum SpacingType: String, Hashable {
            
            case small = "SMALL"
            case big = "BIG"
            case negativeOffset = "negativeOffset"
        }
        
        public init(id: UUID = UUID(), backgroundColor: BackgroundColorType, spacingType: SpacingType) {
            self.id = id
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
