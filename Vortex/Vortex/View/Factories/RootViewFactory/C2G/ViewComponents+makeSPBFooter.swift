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
        event: @escaping () -> Void,
        title: String = "Продолжить"
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
