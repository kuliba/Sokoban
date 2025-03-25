//
//  AmountInputView.swift
//  swift-vortex
//
//  Created by Valentin Ozerov on 21.03.2025.
//

import SharedConfigs
import SwiftUI
import TextFieldDomain
import TextFieldComponent
import InputComponent

public struct AmountInputView<IconView: View>: View {
    
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
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    config.title.text(withConfig: config.titleConfig, alignment: .leading)
                        .offset(y: config.titleOffset)
                    
                    textField()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, config.topPadding)
            }
            
            messageView()
        }
        .transition(.opacity)
        .animation(.bouncy, value: state)
    }
}

public extension AmountInputView {
    
    typealias State = TextInputState
    typealias Event = TextInputEvent
    typealias Config = AmountInputConfig
}

private extension AmountInputView {
    
    func textField() -> some View {
        
        AmountFieldView(
            state: .init(
                get: { state.textField },
                set: { _ in }
            ),
            keyboardType: config.keyboard.uiKeyboardType,
            toolbar: toolbar(),
            send: { event(.textField($0)) },
            textFieldConfig: config.textField
        )
    }
    
    func toolbar() -> AmountToolbarViewModel {
        
        .init(
            doneButton: .init(
                label: .title(config.toolbar.doneTitle),
                action: UIApplication.shared.endEditing
            ),
            closeButton: .init(
                label: .image(config.toolbar.closeImage),
                action: UIApplication.shared.endEditing
            )
        )
    }
    
    @ViewBuilder
    func messageView() -> some View {
        
        state.message.map { message in
            
            switch message.kind {
            case .hint:
                message.text.text(withConfig: config.hint, alignment: .leading)
                    .padding(.leading, 40)
                
            case .warning:
                message.text.text(withConfig: config.warning, alignment: .leading)
                    .padding(.leading, 40)
            }
        }
        .transition(.asymmetric(insertion: .scale, removal: .opacity))
    }
}

// MARK: - Previews

struct AmountInputView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            VStack {
                
                Group {
                    
                    textInputView(textField: .editing(.empty), message: nil)
                    textInputView(textField: .editing(.init("a", cursorAt: 0)), message: nil)
                }
                .border(.red.opacity(0.3))
            }
            
            VStack {
                
                Group {
                    
                    placeholder(message: nil)
                    placeholder(message: .hint(""))
                    placeholder(message: .hint("hint"))
                    placeholder(message: .warning(""))
                    placeholder(message: .warning("warning"))
                    
                    noFocus(text: "", message: nil)
                    noFocus(text: "", message: .warning(""))
                    noFocus(text: "", message: .warning("warning"))
                    noFocus(text: "abc", message: .warning("warning"))
                }
                .border(.red.opacity(0.3))
            }
        }
    }
    
    private static func placeholder(
        message: TextInputState.Message? = nil
    ) -> some  View {
        
        AmountInputView(
            state: .init(textField: .placeholder("placeholder"), message: message),
            event: { print($0) },
            config: .preview,
            iconView: { Color.orange }
        )
    }
    
    private static func noFocus(
        text: String,
        message: TextInputState.Message? = nil
    ) -> some  View {
        
        AmountInputView(
            state: .init(textField: .noFocus(text), message: message),
            event: { print($0) },
            config: .preview,
            iconView: { Color.orange }
        )
    }
    
    private static func textInputView(
        textField: TextFieldState,
        message: TextInputState.Message? = nil
    ) -> some  View {
        
        AmountInputView(
            state: .init(textField: textField, message: message),
            event: { print($0) },
            config: .preview,
            iconView: { Color.orange }
        )
    }
}


