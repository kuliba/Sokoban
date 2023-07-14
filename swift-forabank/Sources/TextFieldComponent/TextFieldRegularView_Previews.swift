//
//  TextFieldRegularView_Previews.swift
//  
//
//  Created by Igor Malyarov on 02.06.2023.
//

import TextFieldModel
import TextFieldUI
import SwiftUI

// MARK: - Preview

struct Previews_TextFieldRegularView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            textFieldRegularView(nil)
            textFieldRegularView("")
            textFieldRegularView("123456789")
            
            TextFieldView(
                viewModel: ReducerTextFieldViewModel(
                    initialState: .editing(.init("ABC", cursorPosition: 2)),
                    reducer: TransformingReducer(placeholderText: "Enter text here"),
                    keyboardType: .decimal,
                    toolbar: .init(doneButton: .init(label: .title("Done"), action: { UIApplication.shared.resignFirstResponder() }))
                ),
                textFieldConfig: .preview
            )
        }
        .padding()
    }
    
    private static func textFieldRegularView(
        _ text: String?
    ) -> TextFieldView {
        
        .init(
            viewModel: ReducerTextFieldViewModel.preview(text),
            textFieldConfig: .preview
        )
    }
}

// MARK: - Preview Content

extension ReducerTextFieldViewModel
where Toolbar == ToolbarViewModel,
      Keyboard == KeyboardType {
    
    static func preview(
        _ text: String?
    ) -> ReducerTextFieldViewModel {
        
        if let text {
            return .preview(initialState: .noFocus(text))
        } else {
            return .preview(initialState: .placeholder("A placeholder"))
        }
    }
    
    static func editing(
        _ textState: TextState,
        keyboardType: KeyboardType = .default
    ) -> ReducerTextFieldViewModel {
        
        .preview(
            initialState: .editing(textState),
            keyboardType: keyboardType
        )
    }
    
    static func preview(
        initialState textState: TextFieldState,
        keyboardType: KeyboardType = .default
    ) -> ReducerTextFieldViewModel {
        
        .init(
            initialState: textState,
            reducer: TransformingReducer(
                placeholderText: "Enter text here"
            ),
            keyboardType: keyboardType,
            toolbar: .preview()
        )
    }
}

private extension TextFieldView.TextFieldConfig {
    
    static let preview: Self = .init(
        font: .systemFont(ofSize: 19),
        textColor: .blue,
        tintColor: .orange,
        backgroundColor: .clear,
        placeholderColor: .gray
    )
}

private extension ToolbarViewModel {
    
    static func preview(
        doneButtonLabel: ButtonViewModel.Label = .title("Done"),
        closeButtonLabel: ButtonViewModel.Label = .title("Close")
    ) -> ToolbarViewModel {
        
        .init(
            doneButton: .init(label: doneButtonLabel, action: {}),
            closeButton: .init(label: closeButtonLabel, action: {})
        )
    }
}
