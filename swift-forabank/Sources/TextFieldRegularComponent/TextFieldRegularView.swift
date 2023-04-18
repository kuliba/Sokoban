//
//  TextFieldRegularView.swift
//  
//
//  Created by Igor Malyarov on 14.04.2023.
//

import Foundation
import SwiftUI
import UIKitHelpers

public struct TextFieldRegularView: UIViewRepresentable {
    
    @ObservedObject private var viewModel: ViewModel
    
    private let textFieldConfig: TextFieldConfig
    
    public init(
        viewModel: ViewModel,
        textFieldConfig: TextFieldConfig
    ) {
        self.viewModel = viewModel
        self.textFieldConfig = textFieldConfig
    }
    
    // MARK: Support Existing API
    
    public init(
        viewModel: ViewModel,
        font: UIFont = .systemFont(ofSize: 19, weight: .regular),
        backgroundColor: Color = .clear,
        tintColor: Color = .black,
        textColor: Color
    ) {
        self.viewModel = viewModel
        self.textFieldConfig = .init(
            font: font,
            textColor: textColor,
            tintColor: tintColor,
            backgroundColor: backgroundColor
        )
    }
    
    public func makeUIView(context: Context) -> UITextView {
        
        let textView = WrappedTextView()
        let viewModel = context.coordinator.viewModel
        let state = viewModel.state
        
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
        
        textView.keyboardType = viewModel.keyboardType.uiKeyboardType
        
        let doneButton = context.coordinator.makeDoneButton(title: "Готово")
        let closeButton = viewModel.toolbar.closeButton.map { _ in
            context.coordinator.makeCloseButton(imageNamed: "Close Button")
        }
        textView.inputAccessoryView = ToolbarFactory.makeToolbar(
            doneButton: doneButton,
            closeButton: closeButton
        )
        
        render(textView, for: viewModel.state, with: textFieldConfig)
        
        return textView
    }
    
    public func updateUIView(_ textView: UITextView, context: Context) {
        
        render(
            textView,
            for: context.coordinator.viewModel.state,
            with: textFieldConfig
        )
    }
    
    public func makeCoordinator() -> Coordinator {
        
        Coordinator(viewModel: viewModel)
    }
    
    private func render(
        _ textView: UITextView,
        for state: ViewModel.State,
        with config: TextFieldConfig
    ) {
        switch state {
        case let .focus(text: text, cursorPosition: cursorPosition):
            textView.text = text
            textView.setCursorPosition(to: cursorPosition)
            textView.textColor = .init(config.textColor)
            
        case let .noFocus(text):
            textView.text = text
            textView.textColor = .lightGray
            
        case let .placeholder(placeholderText):
            textView.text = placeholderText
            textView.textColor = .lightGray
        }
    }
}

// MARK: - Coordinator

extension TextFieldRegularView {
    
    public class Coordinator: NSObject {
        
        let viewModel: ViewModel
        
        init(viewModel: ViewModel) {
            
            self.viewModel = viewModel
            super.init()
        }
        
        @objc func handleDoneAction() {
            viewModel.toolbar.doneButton.action()
        }
        
        @objc func handleCloseAction() {
            viewModel.toolbar.closeButton?.action()
        }
    }
}

// MARK: - UITextViewDelegate

extension TextFieldRegularView.Coordinator: UITextViewDelegate {
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        
        viewModel.textViewDidBeginEditing()
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        
        viewModel.textViewDidEndEditing()
    }
    
    public func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        
        viewModel.shouldChangeTextIn(range: range, replacementText: text)
        
        return false
    }
}

private extension TextFieldRegularView.Coordinator {
    
    func makeDoneButton(title: String) -> UIBarButtonItem {
        
        .init(
            title: title,
            style: .plain,
            target: self,
            action: #selector(handleDoneAction)
        )
    }
    
    func makeCloseButton(imageNamed image: String) -> UIBarButtonItem {
        
        .init(
            image: .init(named: image),
            style: .plain,
            target: self,
            action: #selector(handleCloseAction)
        )
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

extension TextFieldRegularView.ViewModel.KeyboardType {
    
    var uiKeyboardType: UIKeyboardType {
        
        switch self {
        case .default: return .default
        case .number:  return .numberPad
        }
    }
}

// MARK: - Preview

struct Previews_TextFieldRegularView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            textFieldRegularView(nil)
            textFieldRegularView("")
            textFieldRegularView("123456789")
            
            TextFieldRegularView(
                viewModel: .init(
                    state: .focus(text: "ABC", cursorPosition: 2),
                    keyboardType: .default,
                    reducer: .init(placeholderText: "Enter text here"),
                    needCloseButton: true
                ),
                textFieldConfig: .preview
            )
        }
        .padding()
    }
    
    private static func textFieldRegularView(
        _ text: String?
    ) -> TextFieldRegularView {
        
        .init(
            viewModel: .preview(text),
            textFieldConfig: .preview
        )
    }
}

// MARK: - Preview Content

extension TextFieldRegularView.ViewModel {
    
    static func preview(
        _ text: String?
    ) -> TextFieldRegularView.ViewModel {
        
        .init(
            text: text,
            placeholder: "Enter text here",
            keyboardType: .default
        )
    }
}

private extension TextFieldRegularView.TextFieldConfig {
    
    static let preview: Self = .init(
        font: .systemFont(ofSize: 19),
        textColor: .blue,
        tintColor: .orange,
        backgroundColor: .clear
    )
}
