//
//  CancellableSearchView.swift
//
//
//  Created by Igor Malyarov on 10.02.2024.
//

import SwiftUI
import TextFieldDomain
import TextFieldUI

public struct CancellableSearchView<ClearButtonLabel: View, CancelButton: View>: View {
    
    let state: TextFieldState
    let send: (TextFieldAction) -> Void
    
    let clearButtonLabel: () -> ClearButtonLabel
    let cancelButton: () -> CancelButton
    
    let keyboardType: KeyboardType
    let toolbar: ToolbarViewModel?
    let textFieldConfig: TextFieldView.TextFieldConfig
    
    public init(
        state: TextFieldState, 
        send: @escaping (TextFieldAction) -> Void,
        clearButtonLabel: @escaping () -> ClearButtonLabel,
        cancelButton: @escaping () -> CancelButton,
        keyboardType: KeyboardType,
        toolbar: ToolbarViewModel?,
        textFieldConfig: TextFieldView.TextFieldConfig
    ) {
        self.state = state
        self.send = send
        self.clearButtonLabel = clearButtonLabel
        self.cancelButton = cancelButton
        self.keyboardType = keyboardType
        self.toolbar = toolbar
        self.textFieldConfig = textFieldConfig
    }
    
    public var body: some View {
        
        HStack {
            
            TextFieldView(
                state: .init(get: { state }, set: { _ in }),
                keyboardType: keyboardType.uiKeyboardType,
                toolbar: toolbar,
                send: send,
                textFieldConfig: textFieldConfig
            )
            .accessibilityIdentifier("CancellableSearchField")
            
            switch state {
            case .editing(.empty),
                    .noFocus(""),
                    .placeholder:
                cancelButton()
                
            case .editing, .noFocus:
                twoButtons()
            }
        }
    }
    
    private func twoButtons() -> some View {
        
        HStack(spacing: 16) {
            
            clearButton()
            cancelButton()
        }
    }
    
    private func clearButton() -> some View {
        
        Button {
            send(.setTextTo(""))
        } label: {
            clearButtonLabel()
        }
    }
}

struct CancellableSearchView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            cancellableSearchView(.placeholder("placeholder"))
            cancellableSearchView(.noFocus("no focus"))
            cancellableSearchView(.editing(.empty))
            cancellableSearchView(.editing(.init("some text", cursorPosition: 3)))
        }
    }
    
    private static func cancellableSearchView(
        _ state: TextFieldState
    ) -> some View {
        
        CancellableSearchView(
            state: state,
            send: { _ in },
            clearButtonLabel: PreviewClearButton.init,
            cancelButton: PreviewCancelButton.init,
            keyboardType: .default,
            toolbar: nil,
            textFieldConfig: .preview
        )
    }
}
