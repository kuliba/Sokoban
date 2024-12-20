//
//  TogglePreview.swift
//
//
//  Created by Valentin Ozerov on 09.12.2024.
//

import SwiftUI
import SharedConfigs

// MARK: - Previews

struct TogglePreview: View {
    
    @State private(set) var isOn = false
    
    var body: some View {
        
        Toggle("", isOn: $isOn)
            .toggleStyle(ToggleComponentStyle(config: .preview))
    }
}

#Preview {
    
    TogglePreview()
}
