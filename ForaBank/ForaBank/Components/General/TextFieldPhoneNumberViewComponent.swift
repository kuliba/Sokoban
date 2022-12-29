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
        
        let style: Style
        @Published var text: String?
        @Published var state: State
        var dismissKeyboard: () -> Void
        var toolbar: ToolbarViewModel?
        
        let placeHolder: PlaceHolder
        let filterSymbols: [Character]?
        let firstDigitReplaceList: [Replace]?
        
        let phoneNumberFormatter: PhoneNumberFormaterProtocol
        
        var bindings = Set<AnyCancellable>()
        
        init(style: Style = .general, text: String? = nil, placeHolder: PlaceHolder, state: State = .idle, toolbar: ToolbarViewModel? = nil, filterSymbols: [Character]? = nil, firstDigitReplaceList: [Replace]? = nil, phoneNumberFormatter: PhoneNumberFormaterProtocol = PhoneNumberKitFormater()) {
            
            self.style = style
            self.text = text
            self.placeHolder = placeHolder
            self.state = state
            self.toolbar = toolbar
            self.filterSymbols = filterSymbols
            self.firstDigitReplaceList = firstDigitReplaceList
            self.phoneNumberFormatter = phoneNumberFormatter
            self.dismissKeyboard = {}
        }
        
        convenience init(_ placeHolder: PlaceHolder) {
            
            switch placeHolder {
            case .contacts:
                let filterSymbols = [Character("-"), Character("("), Character(")"), Character("+")]
                
                self.init(placeHolder: placeHolder, filterSymbols: filterSymbols, firstDigitReplaceList: [.init(from: "8", to: "7"), .init(from: "9", to: "+7 9")], phoneNumberFormatter: PhoneNumberKitFormater())
                
            default:
                self.init(placeHolder: placeHolder)
            }
            
            self.toolbar = .init(doneButton: .init(isEnabled: true, action: { [weak self] in self?.dismissKeyboard() }),
                                 closeButton: .init(isEnabled: true, action: { [weak self] in self?.dismissKeyboard() }))
        }
        
        enum State {
            
            case idle
            case selected
            case editing
        }
        
        enum Style {
            
            case general
            case payments
        }
        
        enum PlaceHolder {
            
            case contacts
            case banks
            case countries
            case text(String)
            
            var title: String {
                
                switch self {
                case .contacts: return "Номер телефона или имя"
                case .banks: return "Введите название банка"
                case .countries: return "Введите название страны"
                case let .text(text): return text
                }
            }
        }
    }
}

extension TextFieldPhoneNumberView.ViewModel {
    
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
    
    struct Replace {
        
        let from: Character
        let to: String
    }
}

struct TextFieldPhoneNumberView: UIViewRepresentable {
    
    @ObservedObject var viewModel: TextFieldPhoneNumberView.ViewModel
    
    private let textField = UITextField()
    
    func makeUIView(context: Context) -> UITextField {
        
        textField.delegate = context.coordinator
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.shouldHideToolbarPlaceholder = false
        textField.spellCheckingType = .no
        textField.placeholder = viewModel.placeHolder.title
        
        switch viewModel.style {
        case .general:
            textField.keyboardType = .default
            
        case .payments:
            textField.keyboardType = .phonePad
            textField.font = .init(name: "Inter-Medium", size: 14.0)
        }
        
        viewModel.dismissKeyboard = { textField.resignFirstResponder() }
        
        if let toolbarViewModel = viewModel.toolbar {
            
            textField.inputAccessoryView = makeToolbar(toolbarViewModel: toolbarViewModel, context: context)
        }
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        
        uiView.text = viewModel.text
    }
    
    func makeCoordinator() -> Coordinator {
        
        return Coordinator(viewModel: viewModel)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        let viewModel: ViewModel
        
        init(viewModel: ViewModel) {
            
            self.viewModel = viewModel
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            
            viewModel.state = state(for: viewModel.text)
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            
            viewModel.state = .idle
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
            let result = TextFieldPhoneNumberView.updateMasked(value: textField.text, inRange: range, update: string, firstDigitReplace: viewModel.firstDigitReplaceList, phoneFormatter: viewModel.phoneNumberFormatter, filterSymbols: viewModel.filterSymbols)
            
            textField.text = result
            viewModel.text = result
            
            if textField.isFirstResponder {
                
                viewModel.state = state(for: viewModel.text)
                
            } else {
                
                viewModel.state = .idle
            }
            
            return false
        }
        
        @objc func handleDoneAction() {
            viewModel.toolbar?.doneButton.action()
        }
        
        @objc func handleCloseAction() {
            viewModel.toolbar?.closeButton?.action()
        }
        
        func state(for text: String?) -> TextFieldPhoneNumberView.ViewModel.State {
            
            if viewModel.text != nil {
                
                return .editing
                
            } else {
                
                return .selected
            }
        }
    }
    
    static func updateMasked(value: String?, inRange: NSRange, update: String, firstDigitReplace: [TextFieldPhoneNumberView.ViewModel.Replace]?, phoneFormatter: PhoneNumberFormaterProtocol, filterSymbols: [Character]?) -> String? {
        
        if let value = value {
            
            var updatedValue = value
            let rangeStart = value.index(value.startIndex, offsetBy: inRange.lowerBound)
            let rangeEnd = value.index(value.startIndex, offsetBy: inRange.upperBound)
            updatedValue.replaceSubrange(rangeStart..<rangeEnd, with: update)
            
            let filteredValue = updatedValue.replacingOccurrences(of: " ", with: "").filter { char in
                
                if let filterSymbols = filterSymbols {
                    
                    for symbol in filterSymbols {
                        
                        if symbol == char {
                            
                            return false
                        }
                    }
                }
                
                return true
            }
            
            guard filteredValue.isNumeric || phoneFormatter.isValid(update) else {
                return updatedValue.isEmpty ? nil : updatedValue
            }
            
            var phone = updatedValue.digits
            
            if let firstDigitReplace = firstDigitReplace {
                
                for replace in firstDigitReplace {
                    
                    if phone.digits.first == replace.from {
                        
                        phone.replaceSubrange(...phone.startIndex, with: replace.to)
                    }
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
    
    private func makeToolbar(toolbarViewModel: TextFieldPhoneNumberView.ViewModel.ToolbarViewModel, context: Context) -> UIToolbar? {
        
        let coordinator = context.coordinator
        
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


