//
//  StatementDetailLayoutView.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.02.2025.
//

import SwiftUI

struct StatementDetailLayoutView<Buttons: View, Content: View>: View {
    
    let config: Config
    let buttons: () -> Buttons
    let content: () -> Content
    
    var body: some View {
        
        VStack(spacing: config.spacing) {
            
            buttons()
            content()
        }
        .padding(config.insets)
    }
}

extension StatementDetailLayoutView {
    
    typealias Config = StatementDetailLayoutViewConfig
}

struct StatementDetailLayoutViewConfig: Equatable {
    
    let insets: EdgeInsets
    let spacing: CGFloat
}

// MARK: - Previews

#Preview {
    
    StatementDetailLayoutView(
        config: .iVortex,
        buttons: { Color.green },
        content: { Color.blue }
    )
    .border(.red)
}
