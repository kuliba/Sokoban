//
//  TextFieldPhoneFormatableComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 24.10.2022.
//

import Foundation
import SwiftUI
import Combine

extension TextFieldPhoneNumberView {
    
    class ViewModel: ObservableObject {
        
        @Published var text: String?
        @Published var isEditing: Bool
        var dismissKeyboard: () -> Void
        let toolbar: ToolbarViewModel?
        
        let placeHolder: PlaceHolder
        var bindings = Set<AnyCancellable>()
        
        let phoneNumberFormatter = PhoneNumberFormater()
        
        internal init(text: String? = nil, placeHolder: PlaceHolder, isEditing: Bool = false, toolbar: ToolbarViewModel? = nil) {
            
            self.text = text
            self.placeHolder = placeHolder
            self.isEditing = isEditing
            self.toolbar = toolbar
            self.dismissKeyboard = {}
        }
        
        enum PlaceHolder: String {
            
            case contacts = "Номер телефона или имя"
            case banks = "Введите название банка"
        }
    }
}

struct TextFieldPhoneNumberView: UIViewRepresentable {
    
    @ObservedObject var viewModel: TextFieldPhoneNumberView.ViewModel
    
    private let textField = UITextField()
    
    func makeUIView(context: Context) -> UITextField {
        
        textField.delegate = context.coordinator
        textField.keyboardType = .default
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.shouldHideToolbarPlaceholder = false
        textField.spellCheckingType = .no
        textField.placeholder = viewModel.placeHolder.rawValue
        
        viewModel.dismissKeyboard = { textField.resignFirstResponder() }
        
        if viewModel.toolbar != nil {
            textField.inputAccessoryView = makeToolbar(context: context)
        }
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        
        if let text = viewModel.text {
            
            let textRange = NSRange(location: 0, length: text.count)
            let phoneNumberFirstDigitReplaceList: [PhoneNumberFirstDigitReplace] = [.init(from: "8", to: "7"), .init(from: "9", to: "+7 9")]
            uiView.text = TextFieldPhoneNumberView.updateMasked(value: text, inRange: textRange, update: text, firstDigitReplace: phoneNumberFirstDigitReplaceList, phoneFormatter: viewModel.phoneNumberFormatter)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(viewModel: viewModel, text: $viewModel.text)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        var text: Binding<String?>
        @ObservedObject var viewModel: ViewModel
        
        init(viewModel: ViewModel, text: Binding<String?>) {
            
            self.viewModel = viewModel
            self.text = text
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            viewModel.isEditing = false
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            viewModel.isEditing = false
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            let phoneNumberFirstDigitReplaceList: [PhoneNumberFirstDigitReplace] = [.init(from: "8", to: "7"), .init(from: "9", to: "+7 9")]
            textField.text = TextFieldPhoneNumberView.updateMasked(value: textField.text, inRange: range, update: string, firstDigitReplace: phoneNumberFirstDigitReplaceList, phoneFormatter: viewModel.phoneNumberFormatter)
            text.wrappedValue = textField.text
            
            return false
        }
        
        @objc func handleDoneAction() {
            viewModel.toolbar?.doneButton.action()
        }
        
        @objc func handleCloseAction() {
            viewModel.toolbar?.closeButton?.action()
        }
    }
    
    static func updateMasked(value: String?, inRange: NSRange, update: String, firstDigitReplace: [PhoneNumberFirstDigitReplace], phoneFormatter: PhoneNumberFormaterProtocol) -> String? {
        
        let filteredUpdate = update
        
        if let value = value {
            
            var updatedValue = value
            let rangeStart = value.index(value.startIndex, offsetBy: inRange.lowerBound)
            let rangeEnd = value.index(value.startIndex, offsetBy: inRange.upperBound)
            updatedValue.replaceSubrange(rangeStart..<rangeEnd, with: filteredUpdate)
            
            //if user enter letters
            guard updatedValue.digits.count >= 1 else {
                return updatedValue
            }
            
            // need map first digit replace all time update.count > 1 || update.count == 1, because user can past phone type 8 925...
            var phone = updatedValue.digits
            
            for replace in firstDigitReplace {
                
                if phone.digits.first == replace.from {
                    
                    phone.replaceSubrange(...phone.startIndex, with: replace.to)
                }
            }
            
            let phoneFormatted = phoneFormatter.partialFormatter("+\(phone)")
            return phoneFormatted
            
        } else {
            
            guard update.isEmpty == false else {
                return nil
            }
            
            return update
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
        
        toolbarViewModel.doneButton.$isEnabled
            .receive(on: DispatchQueue.main)
            .sink { isEnabled in
                
                doneButton.isEnabled = isEnabled
                
            }.store(in: &viewModel.bindings)
        
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

extension TextFieldPhoneNumberView {
    
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
    
    struct PhoneNumberFirstDigitReplace {
        
        let from: Character
        let to: String
    }
}
