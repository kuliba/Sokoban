//
//  TextFieldView.swift
//
//
//  Created by Igor Malyarov on 14.04.2023.
//

import Foundation
import SwiftUI
import TextFieldDomain
import UIKitHelpers

public struct TextFieldView: UIViewRepresentable {
    
    @Binding var state: TextFieldState
    
    let keyboardType: UIKeyboardType
    let toolbar: ToolbarViewModel?
    let send: (TextFieldAction) -> Void
    
    private let textFieldConfig: TextFieldConfig
    
    public init(
        state: Binding<TextFieldState>,
        keyboardType: UIKeyboardType,
        toolbar: ToolbarViewModel?,
        send: @escaping (TextFieldAction) -> Void,
        textFieldConfig: TextFieldConfig
    ) {
        self._state = state
        self.keyboardType = keyboardType
        self.toolbar = toolbar
        self.send = send
        self.textFieldConfig = textFieldConfig
    }
    
    public func makeUIView(context: Context) -> UITextView {
        
        let textView = WrappedTextView()
        
        textView.delegate = context.coordinator
        
        textView.font = textFieldConfig.font
        textView.backgroundColor = .init(textFieldConfig.backgroundColor)
        textView.tintColor = .init(textFieldConfig.tintColor)
        
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        
        textView.keyboardType = keyboardType
        
        toolbar.map {
            makeToolbar(textView, coordinator: context.coordinator, toolbar: $0)
        }

        return textView
    }
    
    public func updateUIView(_ textView: UITextView, context: Context) {
        
        DispatchQueue.main.async {
            
            switch state {
            case let .editing(textState):
                textView.text = textState.text
                textView.setCursorPosition(to: textState.cursorPosition)
                textView.textColor = .init(textFieldConfig.textColor)
                textView.becomeFirstResponder()
                
            case let .noFocus(text):
                textView.text = text
                textView.textColor = .init(textFieldConfig.textColor)
                if textView.isFirstResponder {
                    DispatchQueue.main.async { [weak textView] in
                        textView?.resignFirstResponder()
                    }
                }
                
            case let .placeholder(placeholderText):
                textView.text = placeholderText
                textView.textColor = .init(textFieldConfig.placeholderColor)
                if textView.isFirstResponder {
                    DispatchQueue.main.async { [weak textView] in
                        textView?.resignFirstResponder()
                    }
                }
            }
        }
    }
    
    private func makeToolbar(
        _ textView: UITextView,
        coordinator: Coordinator,
        toolbar: ToolbarViewModel
    ) {
        let doneButton = coordinator.makeDoneButton(label: toolbar.doneButton.label)
        let closeButton = toolbar.closeButton.map {
            coordinator.makeCloseButton(label: $0.label)
        }
        textView.inputAccessoryView = ToolbarFactory.makeToolbar(
            doneButton: doneButton,
            closeButton: closeButton
        )
    }
    
    public func makeCoordinator() -> Coordinator {
        
        Coordinator(send: send)
    }
}

// MARK: - Coordinator

extension TextFieldView {
    
    public class Coordinator: NSObject {
        
        let send: (TextFieldAction) -> Void
        
        init(send: @escaping (TextFieldAction) -> Void) {
            
            self.send = send
            super.init()
        }
        
        @objc func handleDoneAction() {
            
            DispatchQueue.main.async { [weak self] in
                
                self?.send(.finishEditing)
            }
        }
        
        @objc func handleCloseAction() {
            
            DispatchQueue.main.async { [weak self] in
                
                self?.send(.finishEditing)
            }
        }
        
        // title "Готово"
        func makeDoneButton(
            label: ToolbarViewModel.ButtonViewModel.Label
        ) -> UIBarButtonItem {
            
            makeButton(label: label, action: #selector(handleDoneAction))
        }
        
        // imageNamed: "Close Button"
        func makeCloseButton(
            label: ToolbarViewModel.ButtonViewModel.Label
        ) -> UIBarButtonItem {
            
            makeButton(label: label, action: #selector(handleCloseAction))
        }
        
        func makeButton(
            label: ToolbarViewModel.ButtonViewModel.Label,
            action: Selector
        ) -> UIBarButtonItem {
            
            switch label {
            case let .title(title):
                return .init(
                    title: title,
                    style: .plain,
                    target: self,
                    action: action
                )
                
            case let .image(image):
                return .init(
                    image: .init(named: image),
                    style: .plain,
                    target: self,
                    action: action
                )
            }
        }
    }
}

// MARK: - UITextViewDelegate

extension TextFieldView.Coordinator: UITextViewDelegate {
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.send(.startEditing)
        }
    }
        
    public func textViewDidEndEditing(_ textView: UITextView) {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.send(.finishEditing)
        }
    }
    
    public func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.send(.changeText(text, in: range))
        }
        return false
    }
}

// MARK: - Helpers

private extension UITextView {
    
    func setCursorPosition(to newPosition: Int?) {
        
        guard let newPosition = newPosition,
              // only if there is a currently selected range
              self.selectedTextRange != nil,
              // and only if the new position is valid
              let newPosition = self.position(from: self.beginningOfDocument, offset: newPosition)
        else { return }
        
        // set the new position
        self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
    }
}
