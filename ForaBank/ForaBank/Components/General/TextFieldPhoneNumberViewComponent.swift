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
        @Published var isSelected: Bool
        var dismissKeyboard: () -> Void
        let toolbar: ToolbarViewModel?
        
        let placeHolder: PlaceHolder
        let filtersSymbols: [Character]?
        
        let phoneNumberFormatter: PhoneNumberFormaterProtocol
        let phoneNumberFirstDigitReplaceList: [PhoneNumberFirstDigitReplace]

        var bindings = Set<AnyCancellable>()
        
        init(text: String? = nil, placeHolder: PlaceHolder, isEditing: Bool = false, isSelected: Bool = false, toolbar: ToolbarViewModel? = nil, filtersSymbols: [Character]? = nil, phoneNumberFirstDigitReplaceList: [PhoneNumberFirstDigitReplace], phoneNumberFormatter: PhoneNumberFormaterProtocol = PhoneNumberKitFormater()) {
            
            self.text = text
            self.placeHolder = placeHolder
            self.isEditing = isEditing
            self.isSelected = isSelected
            self.toolbar = toolbar
            self.filtersSymbols = filtersSymbols
            self.phoneNumberFirstDigitReplaceList = phoneNumberFirstDigitReplaceList
            self.phoneNumberFormatter = phoneNumberFormatter
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
            uiView.text = TextFieldPhoneNumberView.updateMasked(value: text, inRange: textRange, update: text, firstDigitReplace: viewModel.phoneNumberFirstDigitReplaceList, phoneFormatter: viewModel.phoneNumberFormatter, filterSymbols: viewModel.filtersSymbols)
        } else {
            
            uiView.text = viewModel.text
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
            
            viewModel.isSelected = true
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            textField.text = TextFieldPhoneNumberView.updateMasked(value: textField.text, inRange: range, update: string, firstDigitReplace: viewModel.phoneNumberFirstDigitReplaceList, phoneFormatter: viewModel.phoneNumberFormatter, filterSymbols: viewModel.filtersSymbols)
            text.wrappedValue = textField.text
            
            return false
        }
        
        @objc func handleDoneAction() {
            viewModel.toolbar?.doneButton.action()
            viewModel.isSelected = false
        }
        
        @objc func handleCloseAction() {
            viewModel.toolbar?.closeButton?.action()
            viewModel.isSelected = false
        }
    }
    
    static func updateMasked(value: String?, inRange: NSRange, update: String, firstDigitReplace: [PhoneNumberFirstDigitReplace], phoneFormatter: PhoneNumberFormaterProtocol, filterSymbols: [Character]?) -> String? {
        
        if let value = value {
            
            var updatedValue = value
            let rangeStart = value.index(value.startIndex, offsetBy: inRange.lowerBound)
            let rangeEnd = value.index(value.startIndex, offsetBy: inRange.upperBound)
            updatedValue.replaceSubrange(rangeStart..<rangeEnd, with: update)
            
            let filterdValue = updatedValue.replacingOccurrences(of: " ", with: "").filter { char in
                
                if let filterSymbols = filterSymbols {
                 
                    for symbol in filterSymbols {
                        
                        if symbol == char {
                            
                            return false
                        }
                    }
                }
                
                return true
            }
            
            guard filterdValue.isNumeric else {
                return updatedValue
            }
            
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
