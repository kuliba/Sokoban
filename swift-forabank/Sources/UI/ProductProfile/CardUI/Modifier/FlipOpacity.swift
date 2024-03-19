//
//  File.swift
//  
//
//  Created by Andryusina Nataly on 19.03.2024.
//

import SwiftUI

public struct FlipOpacity: AnimatableModifier {
    
    var percentage: CGFloat = 0
    
    public init(percentage: CGFloat) {
        self.percentage = percentage
    }
    
    public var animatableData: CGFloat {
        get { percentage }
        set { percentage = newValue }
    }
    
    public func body(content: Content) -> some View {
        content
            .opacity(percentage.rounded())
    }
}
