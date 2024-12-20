//
//  DotsAnimations.swift
//
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import SwiftUI

public struct DotsAnimations : View {
    
    public init() {}
    
    public var body: some View {
        
        HStack(spacing: 3) {
            
            AnimatedDotView(duration: 0.6, delay: 0)
            AnimatedDotView(duration: 0.6, delay: 0.2)
            AnimatedDotView(duration: 0.6, delay: 0.4)
        }
    }
}
