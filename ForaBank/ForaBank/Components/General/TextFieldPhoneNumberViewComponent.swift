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
    
    var textField = UITextField()
    
    @ObservedObject var viewModel: TextFieldPhoneNumberView.ViewModel
    
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
        
        uiView.text = viewModel.text
        
        if viewModel.isEditing {
            
            uiView.resignFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, viewModel: viewModel, text: $viewModel.text)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {

        var text: Binding<String?>
        var delegate: TextFieldPhoneNumberView        
        @ObservedObject var viewModel: ViewModel

        init(_ delegate: TextFieldPhoneNumberView, viewModel: ViewModel, text: Binding<String?>) {
            
            self.viewModel = viewModel
            self.delegate = delegate
            self.text = text
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            viewModel.isEditing = false
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            viewModel.isEditing = false
        }
        
        struct PhoneNumberFirstDigitReplace {
            
            let from: Character
            let to: String
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            // 1. added to textFiel property phoneNumberFirstDigitReplaceList
            // 2. updateMasked change scoup
            // 3. updatedMasked added in arg Formmater phone protocol
            
            let phoneNumberFirstDigitReplaceList: [PhoneNumberFirstDigitReplace] = [.init(from: "8", to: "7"), .init(from: "9", to: "+7 9"), .init(from: "+", to: "+")]
//            textField.text = TextFieldPhoneNumberView.Coordinator.updateMasked(value: textField.text, inRange: range, update: string, firstDigitReplace: phoneNumberFirstDigitReplaceList, phoneFormatter: <#PhoneNumberFormaterProtocol#>)
            text.wrappedValue = textField.text
            
            return false
        }
        
        static func updateMasked(value: String?, inRange: NSRange, update: String, firstDigitReplace: [PhoneNumberFirstDigitReplace], phoneFormatter: PhoneNumberFormaterProtocol) -> String? {
            
            var filteredUpdate = update

            if let value = value {
                
                // +7 925
                var updatedValue = value
                let rangeStart = value.index(value.startIndex, offsetBy: inRange.lowerBound)
                let rangeEnd = value.index(value.startIndex, offsetBy: inRange.upperBound)
                updatedValue.replaceSubrange(rangeStart..<rangeEnd, with: filteredUpdate)
                // +7 9255
                // 79255
                // try formmated number
                // +7 925 5
                // throw +7 9255 // return updatedValue
                guard updatedValue.first?.isHexDigit == true || updatedValue.hasPrefix("+") == true else {
                    return updatedValue
                }
                
                var filterredValue = updatedValue.digits
                
                for replace in firstDigitReplace {
                    
                    if filterredValue.digits.first == replace.from {
                        
                        filterredValue.replaceSubrange(...filterredValue.startIndex, with: replace.to)
                    }
                }
                
                let partialFormatted = PhoneNumberFormater().partialFormatter("+\(filterredValue)")
                
                return partialFormatted
                
            } else {
                // guard update isEmpty == false { return nil }
                if update.count > 1 {
                    
                    // if true remove not digits
                    // try formatted phone
                    // else throw -> update
                } else {
                    // if update.count == 1
                    if let replaced = // try replace phoneNumberFirstDigitReplaceList  {
                        return replaced
                } else {
                    if //try phone formatter {
                    // return
                    //}
                    //else {
                    //return update
                    //}
                    }
                }
                
                for replace in firstDigitReplace {
                    
                    if filteredUpdate.digits.first == replace.from {
                        
                        filteredUpdate.replaceSubrange(...filteredUpdate.startIndex, with: replace.to)
                    }
                }

                let partialFormatted = PhoneNumberFormater().partialFormatter(filteredUpdate)

                return "+\(partialFormatted)"
            }
        }
        
        func updateCursorPosition(_ textField: UITextField) {
            
            let arbitraryValue: Int = 2
            if let newPosition = textField.position(from: textField.endOfDocument, offset: -arbitraryValue) {
                
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
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
