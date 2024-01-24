//
//  ButtonView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SharedConfigs
import SwiftUI

public struct ButtonView: View {
    
    let state: Button
    let event: () -> Void
    let config: ButtonConfig
    
    public init(
        state: Button, 
        event: @escaping () -> Void,
        config: ButtonConfig
    ) {
        self.state = state
        self.event = event
        self.config = config
    }
    
    public var body: some View {
        
        ZStack {
            
            config.active.backgroundColor
            
            SwiftUI.Button(action: event) {
                
                state.value.text(withConfig: config.active.text)
            }
        }
        .frame(height: config.buttonHeight)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Previews

struct ButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
    
        buttonView(.preview)
    }
    
    private static func buttonView(
        _ button: Button
    ) -> some View {
        
        ButtonView(state: .preview, event: {}, config: .preview)
    }
}
