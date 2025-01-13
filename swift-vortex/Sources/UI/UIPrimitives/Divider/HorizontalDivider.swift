//
//  HorizontalDivider.swift
//  
//
//  Created by Andryusina Nataly on 20.06.2024.
//

import SwiftUI

public struct HorizontalDivider: View {
    
    let color: Color
    let height: CGFloat
    
    public init(color: Color, height: CGFloat = 0.5) {
        self.color = color
        self.height = height
    }
    
    public var body: some View {
        color
            .frame(height: height)
    }
}
