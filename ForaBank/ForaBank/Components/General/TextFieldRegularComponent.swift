//
//  TextFieldRegularComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 06.12.2022.
//

import Foundation
import SwiftUI
import Combine

//MARK: - ViewModel

extension TextFieldRegularView {
    
    class ViewModel: ObservableObject {
        
        @Published private(set) var text: String?
        @Published private(set) var cursorPosition: Int?
        @Published private(set) var isEnabled: Bool
        
        private let changeText = PassthroughSubject<String?, Never>()
        let isEditing: CurrentValueSubject<Bool, Never>
       
        let style: Style
        let placeholder: String
        let limit: Int?
        let toolbar: ToolbarViewModel?
        
        var textColor: Color
        
        var hasValue: Bool { text != "" && text != nil }
        
        init(text: String?, cursorPosition: Int? = nil, isEnabled: Bool, isEditing: Bool, placeholder: String, toolbar: ToolbarViewModel?, limit: Int?, style: Style = .default, regExp: String? = nil, textColor: Color) {
            
            self.style = style
            self.text = text
            self.isEnabled = isEnabled
            self.isEditing = .init(isEditing)
            self.placeholder = placeholder
            self.limit = limit
            self.toolbar = toolbar
            self.textColor = textColor
            
            changeText
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .assign(to: &$text)
        }
        
        convenience init(text: String?, placeholder: String, style: Style, limit: Int?, regExp: String? = nil, isEnabled: Bool = true, textColor: Color = .textSecondary) {
            
            let toolbar = ToolbarViewModel(doneButton: .init(isEnabled: true, action: {  UIApplication.shared.endEditing() }))
            
            self.init(text: text, isEnabled: isEnabled, isEditing: false, placeholder: placeholder, toolbar: toolbar, limit: limit, style: style, regExp: regExp, textColor: textColor)
        }
        
        func setText(to text: String?) {
            
            self.changeText.send(text)
        }
    }
}

extension TextFieldRegularView.ViewModel {
    
    func shouldChangeTextIn(range: NSRange, replacementText: String) {
        
        let replaced = text?.replacing(inRange: range, with: replacementText)
        let cursorPosition = range.location + replacementText.count
        let masked = TextFieldRegularView.updateMasked(value: text, inRange: range, update: replacementText, limit: limit, style: style)
        
        setText(to: masked)
        
        // TODO: find a way to set cursor position for masked strings
        if replaced == masked {
            self.cursorPosition = cursorPosition
        }
    }
}

//MARK: - Types

extension TextFieldRegularView.ViewModel {
    
    enum Style {
        
        case `default`
        case number
    }
}

private extension TextFieldRegularView.ViewModel.Style {
    
    var keyboardType: UIKeyboardType {
        
        switch self {
        case .default: return .default
        case .number:  return .numberPad
        }
    }
}

//MARK: - WrappedTextView

class WrappedTextView: UITextView {
    
    private var lastWidth: CGFloat = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds.width != lastWidth {
            
            lastWidth = bounds.width
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        
        let size = sizeThatFits(CGSize(width: lastWidth, height: UIView.layoutFittingExpandedSize.height))
        
        return CGSize(width: size.width.rounded(.up), height: size.height.rounded(.up))
    }
}

//MARK: - View

struct TextFieldRegularView: UIViewRepresentable {
    
    @ObservedObject var viewModel: ViewModel
    
    //TODO: wrapper Font -> UIFont required
    var font: UIFont = .systemFont(ofSize: 19, weight: .regular)
    var backgroundColor: Color = .clear
    var tintColor: Color = .black
    
    func makeUIView(context: Context) -> UITextView {
        
        let textView = WrappedTextView()
        textView.font = font
        textView.backgroundColor = backgroundColor.uiColor()
        textView.textColor = .lightGray
        textView.tintColor = tintColor.uiColor()
        textView.text = viewModel.placeholder
        textView.delegate = context.coordinator
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        
        textView.keyboardType = viewModel.style.keyboardType
        
        if let toolbarViewModel = viewModel.toolbar {
            
            textView.inputAccessoryView = makeToolbar(coordinator: context.coordinator, toolbarViewModel: toolbarViewModel)
        }
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {

        if viewModel.hasValue {

            textView.textColor = viewModel.textColor.uiColor()
            textView.text = viewModel.text
            textView.setCursorPosition(to: viewModel.cursorPosition)
        }
        
        textView.isUserInteractionEnabled = viewModel.isEnabled
    }
    
    func makeCoordinator() -> Coordinator {
        
        Coordinator(viewModel: viewModel, backgroundColor: backgroundColor, textColor: viewModel.textColor, tintColor: tintColor)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        
        let viewModel: ViewModel
        let backgroundColor: Color
        let textColor: Color
        let tintColor: Color
        
        init(viewModel: ViewModel, backgroundColor: Color, textColor: Color, tintColor: Color) {
            
            self.viewModel = viewModel
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.tintColor = tintColor
            super.init()
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            
            if viewModel.hasValue == false {
            
                textView.text = ""
            }
            
            textView.textColor = textColor.uiColor()
            viewModel.isEditing.value = true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            
            if viewModel.hasValue == false {
            
                textView.text = viewModel.placeholder
                textView.textColor = .lightGray
            }
            
            viewModel.isEditing.value = false
        }
        
        @objc func handleDoneAction() {
            viewModel.toolbar?.doneButton.action()
        }
        
        @objc func handleCloseAction() {
            viewModel.toolbar?.closeButton?.action()
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
             
            viewModel.shouldChangeTextIn(range: range, replacementText: text)

            return false
        }
    }
       
    static func updateMasked(value: String?, inRange range: NSRange, update: String, limit: Int?, style: ViewModel.Style) -> String {
        
        guard let value = value else {
            return update.restricted(withLimit: limit, forStyle: style)
        }
        
        return value
            .replacing(inRange: range, with: update)
            .restricted(withLimit: limit, forStyle: style)
    }
    
    private func makeToolbar(coordinator: Coordinator, toolbarViewModel: ToolbarViewModel) -> UIToolbar {
        
        let toolbar = UIToolbar(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        let color: UIColor = .init(hexString: "#1C1C1C")
        let font: UIFont = .systemFont(ofSize: 18, weight: .bold)
        
        let doneButton = UIBarButtonItem(title: "Готово", style: .plain, target: coordinator, action: #selector(coordinator.handleDoneAction))
        doneButton.setTitleTextAttributes([.font: font], for: .normal)
        doneButton.tintColor = color
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var items: [UIBarButtonItem] = [flexibleSpace, doneButton]
        
        if toolbarViewModel.closeButton != nil {
            
            let closeButton = UIBarButtonItem( image: .init(named: "Close Button"), style: .plain, target: coordinator, action: #selector(coordinator.handleCloseAction))
            closeButton.tintColor = color
            
            items.insert(closeButton, at: 0)
        }
        
        toolbar.items = items
        toolbar.barStyle = .default
        toolbar.barTintColor = .white.withAlphaComponent(0)
        toolbar.clipsToBounds = true
        
        return toolbar
    }
}

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
