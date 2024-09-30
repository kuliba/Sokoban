//
//  Spacing.swift
//  
//
//  Created by Andryusina Nataly on 30.09.2024.
//

import Foundation

import SwiftUI

public extension UILanding {
    
    struct Spacing: Equatable  {
        
        let id: UUID
        let backgroundColor: BackgroundColorType
        let sizeDp: CGFloat
        
        public init(
            id: UUID = UUID(),
            backgroundColor: BackgroundColorType,
            sizeDp: CGFloat
        ) {
            self.id = id
            self.backgroundColor = backgroundColor
            self.sizeDp = sizeDp
        }
    }
}

extension UILanding.Spacing {
    
    func imageRequests() -> [ImageRequest] {
        
        return []
    }
}
