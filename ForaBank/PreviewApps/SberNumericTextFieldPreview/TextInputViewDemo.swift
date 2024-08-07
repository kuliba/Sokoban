//
//  TextInputViewDemo.swift
//  
//
//  Created by Igor Malyarov on 07.08.2024.
//

import InputComponent
import SwiftUI
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

private extension TextInputViewDemo {
    
    func textInputView(
        _ state: TextInputState
    ) -> some View {
        
        return TextInputStateWrapperView(
            model: makeModel(state),
            config: .preview
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

extension TextInputState {
    
    static let decimalPlaceholderNoMessage: Self = .preview(keyboard: .decimal, textField: .decimalPlaceholder, message: nil)
    static let decimalPlaceholderHint: Self = .preview(keyboard: .decimal, textField: .decimalPlaceholder, message: .hintPreview)
    static let decimalPlaceholderWarning: Self = .preview(keyboard: .decimal, textField: .decimalPlaceholder, message: .warningPreview)
    
    static let defaultPlaceholderNoMessage: Self = .preview(keyboard: .default, textField: .defaultPlaceholder, message: nil)
    static let defaultPlaceholderHint: Self = .preview(keyboard: .default, textField: .defaultPlaceholder, message: .hintPreview)
    static let defaultPlaceholderWarning: Self = .preview(keyboard: .default, textField: .defaultPlaceholder, message: .warningPreview)
    
    static let numberPlaceholderNoMessage: Self = .preview(keyboard: .number, textField: .numberPlaceholder, message: nil)
    static let numberPlaceholderHint: Self = .preview(keyboard: .number, textField: .numberPlaceholder, message: .hintPreview)
    static let numberPlaceholderWarning: Self = .preview(keyboard: .number, textField: .numberPlaceholder, message: .warningPreview)
    
    static let defaultNpFocusNoMessage: Self = .preview(keyboard: .default, textField: .noFocusPreview, message: nil)
    static let defaultNpFocusHint: Self = .preview(keyboard: .default, textField: .noFocusPreview, message: .hintPreview)
    static let defaultNpFocusWarning: Self = .preview(keyboard: .default, textField: .noFocusPreview, message: .warningPreview)
    
    private static func preview(
        keyboard: KeyboardType,
        title: String = "Text Field Title",
        textField: TextFieldState,
        message: Message?
    ) -> Self {
        
        return .init(
            keyboard: keyboard, 
            title: title,
            textField: textField,
            message: message
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
