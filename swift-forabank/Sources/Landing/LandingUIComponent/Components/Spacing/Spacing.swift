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
        let heightDp: CGFloat
        
        public init(
            id: UUID = UUID(),
            backgroundColor: BackgroundColorType,
            heightDp: CGFloat
        ) {
            self.id = id
            self.backgroundColor = backgroundColor
            self.heightDp = heightDp
        }
    }
}

extension UILanding.Spacing {
    
    func imageRequests() -> [ImageRequest] {
        
        return []
    }
}
