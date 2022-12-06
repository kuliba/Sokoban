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
        @Published var isEditing: Bool
        
        let placeholder: String?
        let toolbar: ToolbarViewModel?
        var becomeFirstResponder: () -> Void
        var dismissKeyboard: () -> Void
        
        init(text: String?, isEnabled: Bool, isEditing: Bool, placeholder: String?, toolbar: ToolbarViewModel?, becomeFirstResponder: @escaping () -> Void, dismissKeyboard: @escaping () -> Void) {
            
            self.text = text
            self.isEnabled = isEnabled
            self.isEditing = isEditing
            self.placeholder = placeholder
            self.toolbar = toolbar
            self.becomeFirstResponder = becomeFirstResponder
            self.dismissKeyboard = dismissKeyboard
        }
        
        convenience init(text: String?, placeholder: String?) {
            
            self.init(text: text, isEnabled: true, isEditing: true, placeholder: placeholder, toolbar: .init(doneButton: .init(isEnabled: true, action: {  UIApplication.shared.endEditing() })), becomeFirstResponder: {}, dismissKeyboard: {})
        }
    }
}

extension TextFieldRegularView {
    
    //TODO: extract to global scoupe
    struct ToolbarViewModel {
        
        let doneButton: ButtonViewModel
        let closeButton: ButtonViewModel?
        
        class ButtonViewModel: ObservableObject {
            
            @Published var isEnabled: Bool
            let action: () -> Void
            
            init(isEnabled: Bool, action: @escaping () -> Void) {
                
                self.isEnabled = isEnabled
                self.action = action
            }
        }
        
        init(doneButton: ButtonViewModel, closeButton: ButtonViewModel? = nil) {
            
            self.doneButton = doneButton
            self.closeButton = closeButton
        }
    }
}

//MARK: - View

struct TextFieldRegularView: UIViewRepresentable {
    
    @ObservedObject var viewModel: ViewModel
    
    //TODO: wrapper Font -> UIFont required
    var font: UIFont = .systemFont(ofSize: 19, weight: .regular)
    var backgroundColor: Color = .clear
    var textColor: Color = .white
    var tintColor: Color = .white
    
    private let textField = UITextField()
    
    func makeUIView(context: Context) -> UITextField {
        
        textField.delegate = context.coordinator
        textField.font = font
        textField.backgroundColor = backgroundColor.uiColor()
        textField.textColor = textColor.uiColor()
        textField.tintColor = tintColor.uiColor()
        textField.placeholder = viewModel.placeholder
        
        textField.addTarget(context.coordinator, action: #selector(context.coordinator.textFieldDidChange(textField:)), for: .editingChanged)
        
        viewModel.becomeFirstResponder = { textField.becomeFirstResponder() }
        viewModel.dismissKeyboard = { textField.resignFirstResponder() }
        
        if viewModel.toolbar != nil {
            textField.inputAccessoryView = makeToolbar(context: context)
        }
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        
        uiView.text = viewModel.text
        uiView.isUserInteractionEnabled = viewModel.isEnabled
    }
    
    func makeCoordinator() -> Coordinator {
        
        Coordinator(viewModel: viewModel)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        let viewModel: ViewModel
        
        init(viewModel: ViewModel) {
            
            self.viewModel = viewModel
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            viewModel.isEditing = true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            viewModel.isEditing = false
        }
        
        @objc func textFieldDidChange(textField: UITextField) {
            
            viewModel.text = textField.text
        }
        
        @objc func handleDoneAction() {
            viewModel.toolbar?.doneButton.action()
        }
        
        @objc func handleCloseAction() {
            viewModel.toolbar?.closeButton?.action()
        }
    }
        
    private func makeToolbar(context: Context) -> UIToolbar? {
        
        let coordinator = context.coordinator
        
        guard let toolbarViewModel = coordinator.viewModel.toolbar else {
            return nil
        }
        
        let toolbar = UIToolbar()
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
        toolbar.sizeToFit()
        
        return toolbar
    }
}

