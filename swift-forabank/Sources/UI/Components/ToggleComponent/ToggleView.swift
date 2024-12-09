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

    public init(isOn: Bool, disabled: Bool) {
        self.isOn = isOn
        self.disabled = disabled
    }
    
    public var body: some View {
        
        Toggle("", isOn: $isOn)
            .toggleStyle(ToggleComponentStyle(config: .preview))
            .disabled(disabled)
    }
}

// MARK: - Previews

#Preview {
    NavigationView {

        @State var isOn = false
        ToggleView(isOn: $isOn, disabled: false)
    }
    .navigationViewStyle(.stack)
}
