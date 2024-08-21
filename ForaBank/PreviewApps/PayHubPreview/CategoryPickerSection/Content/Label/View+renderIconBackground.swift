//
//  View+renderIconBackground.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 21.08.2024.
//

import SwiftUI

extension View {
    
    func renderIconBackground(
        with config: CategoryPickerSectionStateItemLabelConfig.IconBackground
    ) -> some View {
        
        ZStack {
            
            config.color
                .clipShape(RoundedRectangle(cornerRadius: config.radius))
                .frame(config.size)
            
            self
        }
    }
}
