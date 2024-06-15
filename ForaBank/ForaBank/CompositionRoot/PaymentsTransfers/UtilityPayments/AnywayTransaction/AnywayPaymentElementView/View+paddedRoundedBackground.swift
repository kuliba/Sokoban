//
//  View+paddedRoundedBackground.swift
//  ForaBank
//
//  Created by Igor Malyarov on 15.06.2024.
//

import SwiftUI

extension View {
    
    func paddedRoundedBackground(
        color: Color = Color.gray.opacity(0.1),
        cornerRadius: CGFloat = 12
    ) -> some View {
        
        self
            .padding()
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
