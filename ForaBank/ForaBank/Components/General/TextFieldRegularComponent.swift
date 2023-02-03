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
        
        @Published var text: String?
        @Published var isEnabled: Bool
        let isEditing: CurrentValueSubject<Bool, Never>
       
        let style: Style
        let placeholder: String?
        let limit: Int?
        let toolbar: ToolbarViewModel?
        
        var hasValue: Bool { (text != "" && text != nil) ? true : false }
        
        init(text: String?, isEnabled: Bool, isEditing: Bool, placeholder: String?, toolbar: ToolbarViewModel?, limit: Int?, style: Style = .default, regExp: String? = nil) {
            
            self.style = style
            self.text = text
            self.isEnabled = isEnabled
            self.isEditing = .init(isEditing)
            self.placeholder = placeholder
            self.limit = limit
            self.toolbar = toolbar
        }
        
        convenience init(text: String?, placeholder: String?, style: Style, limit: Int?, regExp: String? = nil, isEnabled: Bool = true) {
            
            self.init(text: text, isEnabled: isEnabled, isEditing: false, placeholder: placeholder, toolbar: .init(doneButton: .init(isEnabled: true, action: {  UIApplication.shared.endEditing() })), limit: limit, style: style, regExp: regExp)
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
    var textColor: Color = .black
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
    
        switch viewModel.style {
        case .default:
            textView.keyboardType = .default
            
        case .number:
            textView.keyboardType = .numberPad
        }
        
        if let toolbarViewModel = viewModel.toolbar {
            
            textView.inputAccessoryView = makeToolbar(coordinator: context.coordinator, toolbarViewModel: toolbarViewModel)
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {

        if viewModel.hasValue {
            
            uiView.textColor = textColor.uiColor()
            uiView.text = viewModel.text
        }
        
        uiView.autocapitalizationType = .none
        uiView.autocorrectionType = .no
        
        uiView.isUserInteractionEnabled = viewModel.isEnabled
    }
    
    func makeCoordinator() -> Coordinator {
        
        Coordinator(viewModel: viewModel, backgroundColor: backgroundColor, textColor: textColor, tintColor: tintColor)
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
             
            textView.text = TextFieldRegularView.updateMasked(value: textView.text, inRange: range, update: text, limit: viewModel.limit)
            viewModel.text = textView.text
            
            return false
        }
    }
       
    static func updateMasked(value: String?, inRange: NSRange, update: String, limit: Int?) -> String? {
        
        if let value = value {
            
            // replace value characters with filterred update characters in given range
            var updatedValue = value
            let rangeStart = value.index(value.startIndex, offsetBy: inRange.lowerBound)
            let rangeEnd = value.index(value.startIndex, offsetBy: inRange.upperBound)
            updatedValue.replaceSubrange(rangeStart..<rangeEnd, with: update)
            
            // check limit
            if let limit = limit, limit > 0 {
                
                return String(updatedValue.prefix(limit))
                
            } else {
                
                return updatedValue
            }
            
        } else {
            
            return update
        }
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

