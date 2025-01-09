//
//  MaskedTextFieldView.swift
//  PhoneNumberTextViewPreview
//
//  Created by Igor Malyarov on 09.01.2025.
//

import SwiftUI
import TextFieldModel
import TextFieldUI

struct MaskedTextFieldView: View {
    
    @StateObject private var viewModel: ViewModel
    
    init(
        placeholder: String,
        mask: String,
        keyboardType: KeyboardType
    ) {
        let viewModel = TextFieldFactory.makeMasked(
            placeholder: placeholder,
            mask: mask,
            keyboardType: keyboardType
        )
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        TextFieldView(
            viewModel: viewModel,
            textFieldConfig: .preview(fontSize: 17)
        )
        .wrappedInRoundedRectangle(strokeColor: .orange)
        .animation(.easeInOut, value: viewModel.state)
    }
}

extension TextFieldFactory {
    
    static func makeMasked(
        placeholder: String,
        mask: String,
        keyboardType: KeyboardType
    ) -> ViewModel {
        
        let reducer = TransformingReducer(placeholderText: placeholder)
        
        return .init(
            initialState: .placeholder(placeholder),
            reducer: reducer,
            keyboardType: keyboardType,
            toolbar: nil
        )
    }
}

#Preview {
    
    MaskedTextFieldView(
        placeholder:  "Type phone number here",
        mask:  "+7(___)-___-__-__",
        keyboardType: .number
    )
    .padding()
}
