//
//  ToggleView.swift
//
//
//  Created by Valentin Ozerov on 09.12.2024.
//

import SwiftUI

public struct ToggleView: View {

    @Binding private var isOn: Bool
    
    private let config: ToggleConfig
    
    public init(@Binding isOn: Bool, config: ToggleConfig) {
        
        self._isOn = _isOn
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
