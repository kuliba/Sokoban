//
//  FooterButtonView.swift
//
//
//  Created by Igor Malyarov on 22.06.2024.
//

import SharedConfigs
import SwiftUI

public struct FooterButtonView: View {
    
    public let state: State
    public let event: () -> Void
    public let config: Config
    
    public init(
        state: State,
        event: @escaping () -> Void,
        config: Config
    ) {
        self.state = state
        self.event = event
        self.config = config
    }
    
    public var body: some View {
        
        button(config: buttonConfig())
    }
}

public extension FooterButtonView {
    
    typealias State = FooterState.FooterButton
    typealias Config = FooterButtonConfig
}

private extension FooterButtonView {
    
    func button(config: ButtonStateConfig) -> some View {
        
        SwiftUI.Button(action: event) {
            
            ZStack {
                
                config.backgroundColor
                
                state.title.text(withConfig: config.text)
            }
        }
        .frame(height: self.config.buttonHeight)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
    }
    
    private func buttonConfig() -> ButtonStateConfig {
        
        switch state.state {
        case .active:   return config.active
        case .inactive: return config.inactive
        case .tapped:   return config.tapped
        }
    }
}

struct FooterButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32) {
            
            preview(state: .active)
            preview(state: .inactive)
            preview(state: .tapped)
        }
        .padding(.horizontal)
    }
    
    static func preview(
        _ title: String = "Pay",
        state: FooterState.FooterButton.ButtonState,
        config: FooterButtonConfig = .preview
    ) -> some View {
        
        FooterButtonView(
            state: .init(title: title, state: state),
            event: { print("pay tapped") },
            config: config
        )
    }
}
