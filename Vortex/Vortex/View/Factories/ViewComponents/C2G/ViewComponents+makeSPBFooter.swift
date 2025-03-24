//
//  ViewComponents+makeSPBFooter.swift
//  Vortex
//
//  Created by Igor Malyarov on 16.02.2025.
//

import ButtonComponent
import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makeSPBFooter(
        isActive: Bool,
        title: String = "Продолжить",
        event: @escaping () -> Void
    ) -> some View {
        
        VStack(spacing: 20) {
            
            StatefulButtonView(
                isActive: isActive,
                event: event,
                config: .iVortex(title: title)
            )
            
            Image.ic72Sbp
                .renderingMode(.original)
        }
    }
}
