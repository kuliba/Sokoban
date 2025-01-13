//
//  Spacing.swift
//  
//
//  Created by Andryusina Nataly on 30.09.2024.
//

import SwiftUI

public extension CodableLanding {
    
    struct Spacing: Equatable, Codable {
        
        public let backgroundColor: String
        public let heightDp: CGFloat
        
        public init(backgroundColor: String, heightDp: CGFloat) {
            self.backgroundColor = backgroundColor
            self.heightDp = heightDp
        }
    }
}
