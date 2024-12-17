//
//  File.swift
//  
//
//  Created by Andryusina Nataly on 19.03.2024.
//

import SwiftUI

struct FlipOpacity: AnimatableModifier {
    
    var percentage: CGFloat = 0
        
    var animatableData: CGFloat {
        get { percentage }
        set { percentage = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(percentage.rounded())
    }
}
