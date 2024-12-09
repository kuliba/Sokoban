//
//  ToggleView.swift
//
//
//  Created by Valentin Ozerov on 09.12.2024.
//

import SwiftUI

public struct ToggleView: View {

    @Binding private var isOn: Bool
    var disabled: Bool

    public init(@Binding isOn: Bool, disabled: Bool) {
        self._isOn = _isOn
        self.disabled = disabled
    }
    
    public var body: some View {
        
        Toggle("", isOn: $isOn)
            .toggleStyle(ToggleComponentStyle(config: .preview))
            .disabled(disabled)
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
