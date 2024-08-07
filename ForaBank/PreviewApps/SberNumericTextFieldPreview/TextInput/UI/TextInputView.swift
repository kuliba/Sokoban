//
//  TextInputView.swift
//  SberNumericTextFieldPreview
//
//  Created by Igor Malyarov on 07.08.2024.
//

import TextFieldDomain
import TextFieldUI
import SharedConfigs
import SwiftUI

struct TextInputView<IconView: View>: View {
    
    let state: State
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
        
        TextField("enter text", text: .constant("some text"))
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
        title: String = "Text Field Title",
        _ textField: TextFieldState,
        _ message: TextInputState.Message? = nil
    ) -> some View {
        
        TextInputView(
            state: .init(title: title, textField: textField, message: message),
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
        textFieldConfig: .preview,
        title: .init(
            textFont: .subheadline,
            textColor: .green
        ),
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
}#endif
