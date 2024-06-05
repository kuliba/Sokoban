//
//  View+Shimmering.swift
//
//
//  Created by Дмитрий Савушкин on 05.06.2024.
//

import SwiftUI
import Shimmer

public struct shimmering: ViewModifier {
    
    let bounce: Bool = false
    let duration: Double = 1.5
    
    public func body(content: Content) -> some View {
        
        content
            .shimmering(duration: duration, bounce: bounce)
    }
}
