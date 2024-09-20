//
//  TextInputViewDemo.swift
//
//
//  Created by Igor Malyarov on 07.08.2024.
//

import InputComponent
import SwiftUI
import TextFieldComponent
import TextFieldComponent

struct TextInputViewDemo: View {
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack {
                
                textInputView(.decimalPlaceholderNoMessage)
                textInputView(.decimalPlaceholderHint)
                textInputView(.decimalPlaceholderWarning)
                
                textInputView(.defaultPlaceholderNoMessage)
                textInputView(.defaultPlaceholderHint)
                textInputView(.defaultPlaceholderWarning)
                
                textInputView(.numberPlaceholderNoMessage)
                textInputView(.numberPlaceholderHint)
                textInputView(.numberPlaceholderWarning)
                
                textInputView(.defaultNpFocusNoMessage)
                textInputView(.defaultNpFocusHint)
                textInputView(.defaultNpFocusWarning)
            }
        }
    }
}

struct TextInputDemoState: Equatable {
    
    let keyboard: KeyboardType
    let textInput: TextInputState
    let title: String
}

private extension TextInputViewDemo {
    
    func textInputView(
        _ state: TextInputDemoState
    ) -> some View {
        
        return TextInputStateWrapperView(
            model: makeModel(state.textInput),
            config: .preview(
                keyboard: state.keyboard,
                title: state.title
            )
        ) {
            Image(systemName: "photo")
        }
    }
    
    func makeModel(
        placeholderText: String = "placeholder",
        _ state: TextInputState
    ) -> TextInputModel {
        
        let textFieldReducer = TransformingReducer.sberNumericReducer(
            placeholderText: placeholderText
        )
        let textInputValidator = TextInputValidator(
            hintText: "Long hint describing how to fill up this field without errors.",
            warningText: "This text describes text input validation error.",
            validate: { $0.count > 4 }
        )
        let reducer = TextInputReducer(
            textFieldReduce: textFieldReducer.reduce(_:_:),
            validate: textInputValidator.validate
        )
        let effectHandler = TextInputEffectHandler()
        
        return .init(
            initialState: state,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
}

private extension Reducer {
    
    func reduce(
        _ state: TextFieldState,
        _ action: TextFieldAction
    ) -> TextFieldState {
        
        do {
            return try reduce(state, with: action)
        } catch {
            return state
        }
    }
}

#Preview {
    
    TextInputViewDemo()
}

extension TextInputDemoState {
    
    static let decimalPlaceholderNoMessage: Self = .preview(.decimal, message: nil, textField: .decimalPlaceholder)
    static let decimalPlaceholderHint: Self = .preview(.decimal, message: .hintPreview, textField: .decimalPlaceholder)
    static let decimalPlaceholderWarning: Self = .preview(.decimal, message: .warningPreview, textField: .decimalPlaceholder)
    
    static let defaultPlaceholderNoMessage: Self = .preview(.default, message: nil, textField: .defaultPlaceholder)
    static let defaultPlaceholderHint: Self = .preview(.default, message: .hintPreview, textField: .defaultPlaceholder)
    static let defaultPlaceholderWarning: Self = .preview(.default, message: .warningPreview, textField: .defaultPlaceholder)
    
    static let numberPlaceholderNoMessage: Self = .preview(.number, message: nil, textField: .numberPlaceholder)
    static let numberPlaceholderHint: Self = .preview(.number, message: .hintPreview, textField: .numberPlaceholder)
    static let numberPlaceholderWarning: Self = .preview(.number, message: .warningPreview, textField: .numberPlaceholder)
    
    static let defaultNpFocusNoMessage: Self = .preview(.default, message: nil, textField: .noFocusPreview)
    static let defaultNpFocusHint: Self = .preview(.default, message: .hintPreview, textField: .noFocusPreview)
    static let defaultNpFocusWarning: Self = .preview(.default, message: .warningPreview, textField: .noFocusPreview)
    
    private static func preview(
        _ keyboard: KeyboardType,
        message: TextInputState.Message?,
        textField: TextFieldState,
        _ title: String = "Text Field Title"
    ) -> Self {
        
        return .init(
            keyboard: keyboard,
            textInput: .init(textField: textField, message: message),
            title: title
        )
    }
}

extension TextFieldState {
    
    static let decimalPlaceholder: Self = .placeholder("decimal placeholder")
    static let defaultPlaceholder: Self = .placeholder("default placeholder")
    static let numberPlaceholder: Self = .placeholder("number placeholder")
    
    static let editingPreview: Self = .editing(.init("tex"))
    static let noFocusPreview: Self = .noFocus("noFocus: entered text.")
}

extension TextInputState.Message {
    
    static let hintPreview: Self = .hint("Long hint describing how to fill up this field without errors.")
    static let warningPreview: Self = .warning("This text describes text input validation error.")
}

extension TextInputConfig {
    
    static func preview(
        keyboard: KeyboardType,
        title: String
    ) -> Self {
        
        return .init(
            hint: .init(
                textFont: .footnote,
                textColor: .orange
            ),
            imageWidth: 24,
            keyboard: keyboard,
            placeholder: "Введите значение",
            textField: .preview,
            title: title,
            titleConfig: .init(
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
