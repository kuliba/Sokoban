//
//  StatefulButtonView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SharedConfigs
import SwiftUI

public struct StatefulButtonView: View {
    
    let isActive: Bool
    let event: () -> Void
    let config: StatefulButtonConfig
    
    public init(
        isActive: Bool,
        event: @escaping () -> Void,
        config: StatefulButtonConfig
    ) {
        self.isActive = isActive
        self.event = event
        self.config = config
    }
    
    public var body: some View {
        
        SwiftUI.Button(action: event) {
            
            ZStack {
                
                backgroundColor
                
                text.text(withConfig: textConfig)
            }
        }
        .frame(height: config.buttonHeight)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
        .disabled(!isActive)
    }
}

private extension StatefulButtonView {
    
    var backgroundColor: Color {
        
        isActive ? config.active.backgroundColor : config.inactive.backgroundColor
    }
    
    var text: String {
        
        isActive ? config.active.title.text : config.inactive.title.text
    }
    
    var textConfig: TextConfig {
        
        isActive ? config.active.title.config : config.inactive.title.config
    }
}

// MARK: - Previews

struct StatefulButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32) {
            
            buttonView(false)
            buttonView(true)
        }
    }
    
    private static func buttonView(
        _ isActive: Bool
    ) -> some View {
        
        StatefulButtonView(isActive: isActive, event: {}, config: .preview)
    }
}
