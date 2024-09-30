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
        public let sizeDp: CGFloat
        
        public init(backgroundColor: String, sizeDp: CGFloat) {
            self.backgroundColor = backgroundColor
            self.sizeDp = sizeDp
        }
    }
}
