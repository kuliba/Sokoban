//
//  View+paddedRoundedBackground.swift
//  Vortex
//
//  Created by Igor Malyarov on 15.06.2024.
//

import SwiftUI

extension View {
    
    func paddedRoundedBackground(
        horizontal: CGFloat = 16,
        vertical: CGFloat = 13,
        color: Color = .mainColorsGrayLightest,
        cornerRadius: CGFloat = 12
    ) -> some View {
        
        self
            .padding(.horizontal, horizontal)
            .padding(.vertical, vertical)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
