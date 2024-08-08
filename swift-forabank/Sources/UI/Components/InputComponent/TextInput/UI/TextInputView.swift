//
//  TextInputView.swift
//  
//
//  Created by Igor Malyarov on 07.08.2024.
//

import SharedConfigs
import SwiftUI
import TextFieldDomain
import TextFieldComponent

public struct TextInputView<IconView: View>: View {
    
    private let state: State
    private let event: (Event) -> Void
    private let config: Config
    private let iconView: () -> IconView
    
    public init(
        state: State, 
        event: @escaping (Event) -> Void,
        config: Config,
        iconView: @escaping () -> IconView
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.iconView = iconView
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            HStack(alignment: .center, spacing: 16) {
                
                iconView()
                    .frame(width: config.imageWidth, height: config.imageWidth)
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    state.title.text(withConfig: config.title, alignment: .leading)
                    
                    textField()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            messageView()
        }
        .transition(.opacity)
        .animation(.bouncy)
    }
}

public extension TextInputView {
    
    typealias State = TextInputState
    typealias Event = TextInputEvent
    typealias Config = TextInputConfig
}

private extension TextInputView {
    
    func textField() -> some View {
        
        TextFieldView(
            state: .init(
                get: { state.textField },
                set: { _ in }
            ),
            keyboardType: state.keyboard.uiKeyboardType,
            toolbar: toolbar(),
            send: { event(.textField($0)) },
            textFieldConfig: config.textField
        )
    }
    
    func toolbar() -> ToolbarViewModel {
        
        ToolbarFactory.makeToolbarViewModel(
            closeButtonLabel: .image(config.toolbar.closeImage),
            closeButtonAction: UIApplication.shared.endEditing,
            doneButtonLabel: .title(config.toolbar.doneTitle),
            doneButtonAction: UIApplication.shared.endEditing
        )
    }
    
    @ViewBuilder
    func messageView() -> some View {
        
        Group {
            
            switch state.message {
            case .none:
                EmptyView()
                
            case let .some(message):
                switch message.kind {
                case .hint:
                    message.text.text(withConfig: config.hint, alignment: .leading)
                        .padding(.leading, 40)
                    
                case .warning:
                    message.text.text(withConfig: config.warning, alignment: .leading)
                        .padding(.leading, 40)
                }
            }
        }
        .transition(.asymmetric(insertion: .scale, removal: .opacity))
    }
}
