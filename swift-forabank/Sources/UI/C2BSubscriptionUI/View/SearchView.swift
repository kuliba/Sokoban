//
//  SearchView.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

import SearchBarComponent
import SwiftUI
import TextFieldComponent

public struct SearchView: View {
    
    let textFieldState: TextFieldState
    let event: (TextFieldAction) -> Void
    let textFieldConfig: TextFieldView.TextFieldConfig
    
    public init(
        textFieldState: TextFieldState, 
        event: @escaping (TextFieldAction) -> Void,
        textFieldConfig: TextFieldView.TextFieldConfig
    ) {
        self.textFieldState = textFieldState
        self.event = event
        self.textFieldConfig = textFieldConfig
    }
    
    public var body: some View {
        
        CancellableSearchView(
            state: textFieldState,
            send: event,
            clearButtonLabel: PreviewClearButton.init,
            cancelButton: { PreviewCancelButton {
                
                event(.setTextTo(nil))
            }},
            keyboardType: .default,
            toolbar: nil,
            textFieldConfig: textFieldConfig
        )
    }
}

struct SearchView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        SearchView(
            textFieldState: .noFocus("abc123"),
            event: { _ in },
            textFieldConfig: .preview
        )
    }
}
