//
//  File.swift
//  
//
//  Created by Andryusina Nataly on 19.03.2024.
//

import SwiftUI

public struct FlipOpacity: AnimatableModifier {
    
    public var percentage: CGFloat
        
    public var animatableData: CGFloat {
        get { percentage }
        set { percentage = newValue }
    }
    
    public init(percentage: CGFloat = 0) {
        self.percentage = percentage
    }
    
    public func body(content: Content) -> some View {
        content
            .opacity(percentage.rounded())
    }
}
