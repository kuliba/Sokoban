//
//  TextInputView.swift
//  SberNumericTextFieldPreview
//
//  Created by Igor Malyarov on 07.08.2024.
//

import SharedConfigs
import SwiftUI
import TextFieldDomain
import TextFieldComponent

struct TextInputView<IconView: View>: View {
    
    let state: State
    let event: (TextFieldAction) -> Void
    let config: Config
    let iconView: () -> IconView
    
    var body: some View {
        
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

extension TextInputView {
    
    typealias State = TextInputState
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
            send: event,
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

#if DEBUG
struct TextInputView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TextInputViewDemo()
    }
}
#endif
