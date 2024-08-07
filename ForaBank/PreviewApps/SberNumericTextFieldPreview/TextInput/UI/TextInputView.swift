//
//  TextInputView.swift
//  SberNumericTextFieldPreview
//
//  Created by Igor Malyarov on 07.08.2024.
//

import TextFieldDomain
import TextFieldComponent
import SharedConfigs
import SwiftUI

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
            closeButtonAction: {
                UIApplication.shared.endEditing()
            },
            doneButtonLabel: .title(config.toolbar.doneTitle),
            doneButtonAction: { UIApplication.shared.endEditing() }
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
        
        ScrollView(showsIndicators: false) {
            
            VStack {
                
                textInputView(.placeholderPreview, nil)
                textInputView(.placeholderPreview, .hintPreview)
                textInputView(.placeholderPreview, .warningPreview)
                
                textInputView(.editingPreview, nil)
                textInputView(.editingPreview, .hintPreview)
                textInputView(.editingPreview, .warningPreview)
                
                textInputView(.noFocusPreview, nil)
                textInputView(.noFocusPreview, .hintPreview)
                textInputView(.noFocusPreview, .warningPreview)
            }
        }
    }
    
    private static func textInputView(
        keyboard: KeyboardType = .decimal,
        title: String = "Text Field Title",
        _ textField: TextFieldState,
        _ message: TextInputState.Message? = nil
    ) -> some View {
        
        TextInputView(
            state: .init(
                keyboard: keyboard,
                title: title,
                textField: textField,
                message: message
            ),
            event: { print($0) },
            config: .preview
        ) {
            Image(systemName: "photo")
        }
    }
}

extension TextFieldState {
    
    static let placeholderPreview: Self = .placeholder("placeholder")
    static let editingPreview: Self = .editing(.init("tex"))
    static let noFocusPreview: Self = .noFocus("entered text.")
}

extension TextInputState.Message {
    
    static let hintPreview: Self = .hint("Long hint describing how to fill up this field without errors.")
    static let warningPreview: Self = .warning("This text describes text input validation error.")
}

extension TextInputConfig {
    
    static let preview: Self = .init(
        hint: .init(
            textFont: .footnote,
            textColor: .orange
        ),
        imageWidth: 24,
        textField: .preview,
        title: .init(
            textFont: .subheadline,
            textColor: .green
        ),
        toolbar: .preview,
        warning: .init(
            textFont: .footnote,
            textColor: .red
        )
    )
}

extension TextFieldView.TextFieldConfig {
    
    static let preview: Self = .init(
        font: .systemFont(ofSize: 18),
        textColor: .black,
        tintColor: .red,
        backgroundColor: .clear,
        placeholderColor: .pink
    )
}

extension ToolbarConfig {
    
    static let preview: Self = .init(
        closeImage: "closeImage",
        doneTitle: "Done!"
    )
}
#endif
