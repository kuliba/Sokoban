//
//  StatementDetailLayoutView.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.02.2025.
//

import SwiftUI

public struct StatementDetailLayoutView<Buttons: View, Content: View>: View {
    
    private let config: Config
    private let buttons: () -> Buttons
    private let content: () -> Content
    
    public init(
        config: Config,
        buttons: @escaping () -> Buttons,
        content: @escaping () -> Content
    ) {
        self.config = config
        self.buttons = buttons
        self.content = content
    }
    
    public var body: some View {
        
        VStack(spacing: config.spacing) {
            
            buttons()
            content()
        }
        .padding(config.insets)
    }
}

public extension StatementDetailLayoutView {
    
    typealias Config = StatementDetailLayoutViewConfig
}

// MARK: - Previews

#Preview {
    
    StatementDetailLayoutView(
        config: .preview,
        buttons: { Color.green },
        content: { Color.blue }
    )
    .border(.red)
}
