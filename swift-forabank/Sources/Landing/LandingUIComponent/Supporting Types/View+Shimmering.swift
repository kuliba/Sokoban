//
//  View+Shimmering.swift
//  
//
//  Created by Andryusina Nataly on 19.09.2023.
//

import SwiftUI
import Shimmer

public struct shimmering: ViewModifier {
    
    let bounce: Bool = false
    
    public func body(content: Content) -> some View {
        
        content
            .shimmering(bounce: bounce)
    }
}
