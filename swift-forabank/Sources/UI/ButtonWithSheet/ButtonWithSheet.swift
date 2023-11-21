//
//  ButtonWithSheet.swift
//
//
//  Created by Igor Malyarov on 21.11.2023.
//

import SwiftUI

public struct ButtonWithSheet<ButtonLabel: View>: View {
    
    private let action: () -> Void
    private let label: () -> ButtonLabel
    
    public init(
        action: @escaping () -> Void,
        label: @escaping () -> ButtonLabel
    ) {
        self.action = action
        self.label = label
    }
    
    public var body: some View {
        
        Button(action: action, label: label)
    }
}

#Preview {
    ButtonWithSheet(action: {}) {
        
        Image(systemName: "square.and.arrow.up.on.square")
    }
}
