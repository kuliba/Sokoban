//
//  View+paddedRoundedBackground.swift
//  ForaBank
//
//  Created by Igor Malyarov on 15.06.2024.
//

import SwiftUI

extension View {
    
    func paddedRoundedBackground(
        color: Color = .mainColorsGrayLightest,
        cornerRadius: CGFloat = 12
    ) -> some View {
        
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
