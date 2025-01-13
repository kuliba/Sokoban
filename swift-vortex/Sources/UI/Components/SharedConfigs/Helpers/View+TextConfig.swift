//
//  View+TextConfig.swift
//
//
//  Created by Igor Malyarov on 23.12.2023.
//

import SwiftUI

public extension View {
    
    func apply(config: TextConfig) -> some View {
        
        self
            .font(config.textFont)
            .foregroundColor(config.textColor)
    }
}
