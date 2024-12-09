//
//  ToggleView.swift
//
//
//  Created by Valentin Ozerov on 09.12.2024.
//

import SwiftUI
import SharedConfigs

public struct ToggleView: View {

    @Binding private var isOn: Bool
    
    private let config: ToggleConfig
    
    public init(isOn: Binding<Bool>, config: ToggleConfig) {
        
        self._isOn = isOn
        self.config = config
    }
    
    public var body: some View {
        
        Toggle("", isOn: $isOn)
            .toggleStyle(ToggleComponentStyle(config: .preview))
    }
}

// MARK: - Previews

struct PreviewToggle: View {
    
    @State private(set) var isOn = false
    
    var body: some View {
        
        Toggle("", isOn: $isOn)
            .toggleStyle(ToggleComponentStyle(config: .preview))
    }
}

#Preview {
    
    PreviewToggle()
}
