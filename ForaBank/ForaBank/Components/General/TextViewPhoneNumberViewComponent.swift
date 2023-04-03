//
//  TextFieldPhoneFormatableComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 24.10.2022.
//

import Foundation
import SwiftUI
import Combine

extension TextViewPhoneNumberView {
    
    class ViewModel: ObservableObject {
        
        @Published var text: String?
        @Published var state: State
        let isEditing: CurrentValueSubject<Bool, Never>

        var toolbar: ToolbarViewModel?
        var dismissKeyboard: () -> Void
        var bindings = Set<AnyCancellable>()
        
        let style: Style
        let placeHolder: PlaceHolder
        let filterSymbols: [Character]?
        let firstDigitReplaceList: [Replace]?
        
        let phoneNumberFormatter: PhoneNumberFormaterProtocol
        
        var hasValue: Bool { (text != "" && text != nil) ? true : false }

        init(style: Style = .general, text: String? = nil, placeHolder: PlaceHolder, isEditing: Bool = false, state: State = .idle, toolbar: ToolbarViewModel? = nil, filterSymbols: [Character]? = nil, firstDigitReplaceList: [Replace]? = nil, phoneNumberFormatter: PhoneNumberFormaterProtocol = PhoneNumberKitFormater()) {
            
            self.style = style
            self.text = text
            self.placeHolder = placeHolder
            self.isEditing = .init(isEditing)
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
        
        convenience init(style: Style, placeHolder: PlaceHolder) {
            
            switch placeHolder {
            case .phone:
                
                let symbols: [Character] = ["-", "(", ")", "+"]
                let replaceList: [Replace] = [.init(from: "8", to: "7"), .init(from: "9", to: "+7 9")]
                
                self.init(style: style, placeHolder: placeHolder, filterSymbols: symbols, firstDigitReplaceList: replaceList)
            
            default:
                self.init(style: style, placeHolder: placeHolder, state: .idle)
            }
            
            toolbar = .init(doneButton: .init(isEnabled: true) { [weak self] in
                self?.dismissKeyboard()
            }, closeButton: .init(isEnabled: true) { [weak self] in
                self?.dismissKeyboard()
            })
        }
        
        var isActive: Bool {
           
            if state == .selected {
                return true
            }
            
            if let text = text, text.isEmpty == false {
                return true
            }
            
            return false
        }
        
        enum State {
            
            case idle
            case selected
            case editing
        }
        
        enum Style {
            
            case general
            case payments
            case order
            case banks
            case abroad
        }
        
        enum PlaceHolder {
            
            case contacts
            case banks
            case countries
            case phone
            case smsCode
            case text(String)
            
            var title: String {
                
                switch self {
                case .contacts: return "Номер телефона или имя"
                case .banks: return "Введите название банка"
                case .countries: return "Поиск"
                case .phone: return "Мобильный телефон"
                case .smsCode: return "Введите код из СМС"
                case let .text(text): return text
                }
            }
        }
    }
}

extension TextViewPhoneNumberView.ViewModel {
    
    struct Replace {
        
        let from: Character
        let to: String
    }
}

struct TextViewPhoneNumberView: UIViewRepresentable {
    
    @ObservedObject var viewModel: TextViewPhoneNumberView.ViewModel
    
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
        textView.text = viewModel.placeHolder.title
        textView.delegate = context.coordinator
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        switch viewModel.style {
        case .general, .banks, .abroad:
            textView.keyboardType = .default
            
        case .payments:
            textView.keyboardType = .phonePad
            textView.font = .init(name: "Inter-Medium", size: 16.0)
        
        case .order:
            textView.keyboardType = .decimalPad
            textView.font = .init(name: "Inter", size: 16)
        }
        
        viewModel.dismissKeyboard = { textView.resignFirstResponder() }
        
        if let toolbarViewModel = viewModel.toolbar {
            
            textView.inputAccessoryView = makeToolbar(toolbarViewModel: toolbarViewModel, context: context)
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
            viewModel.state = state(for: viewModel.text)
            viewModel.isEditing.value = true

        }
        
        func textViewDidEndEditing(_ textView: UITextView) {

            if viewModel.hasValue == false {
            
                textView.text = viewModel.placeHolder.title
                textView.textColor = .lightGray
            }
            
            viewModel.state = .idle
            viewModel.isEditing.value = false
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
            switch viewModel.style {
            case .order:
                let result = TextViewPhoneNumberView.updateMasked(value: textView.text, inRange: range, update: text, firstDigitReplace: viewModel.firstDigitReplaceList, phoneFormatter: viewModel.phoneNumberFormatter, filterSymbols: viewModel.filterSymbols)
                
                let isValidate = isOrderValidate(textView, result: result)
                
                switch isValidate {
                case true: break
                case false: return isValidate
                }
                
                textView.text = result
                viewModel.text = result
            
            case .banks:
                let result = TextFieldRegularView.updateMasked(value: textView.text, inRange: range, update: text, limit: nil)
                
                textView.text = result
                viewModel.text = result
                
            case .abroad:
                let result = TextFieldRegularView.updateMasked(value: textView.text, inRange: range, update: text, limit: nil)?.filter({$0.isLetter})
                    
                textView.text = result
                viewModel.text = result
            
            case .payments:
                let result = TextViewPhoneNumberView.updateMasked(value: textView.text, inRange: range, update: text, firstDigitReplace: viewModel.firstDigitReplaceList, phoneFormatter: viewModel.phoneNumberFormatter, filterSymbols: viewModel.filterSymbols)
                
                textView.text = result
                viewModel.text = result
                
            default:
                let result = TextFieldRegularView.updateMasked(value: textView.text, inRange: range, update: text, limit: nil)
                
                textView.text = result
                viewModel.text = result
            }

            if textView.isFirstResponder {
                
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
        
        func state(for text: String?) -> TextViewPhoneNumberView.ViewModel.State {
            
            if viewModel.text != nil {
                
                return .editing
                
            } else {
                
                return .selected
            }
        }
        
        private func isOrderValidate(_ textView: UITextView, result: String?) -> Bool {
            
            if let text = result, viewModel.phoneNumberFormatter.isValid(text) {
                
                textView.text = result
                viewModel.text = result
                
                return false
                
            } else {
                
                if let text = textView.text, let result = result {
                    
                    let expectedCharacters = "0123456789"
                    
                    let filterredText = text.filter { expectedCharacters.contains($0) }
                    let filterredResult = result.filter { expectedCharacters.contains($0) }
                    
                    if filterredResult.count > filterredText.count, filterredText.count == 11 {
                        return false
                    }
                }
            }
            
            return true
        }
    }
    
#warning("Hardcoded phoneMaxLength in `limit` parameter default value. Need to replace with data from the backend.")
    static func updateMasked(value: String?, inRange: NSRange, update: String, firstDigitReplace: [TextViewPhoneNumberView.ViewModel.Replace]?, phoneFormatter: PhoneNumberFormaterProtocol, filterSymbols: [Character]?, limit: Int? = 18) -> String? {
        
        if let value = value {
            
            let didAddToValidPhone = phoneFormatter.isValid(value) && inRange.length == 0
            
            guard !didAddToValidPhone else {
                return value
            }
                    
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
                return updatedValue.isEmpty ? nil : value
            }
            
            var phone = updatedValue.digits
            
            if let firstDigitReplace = firstDigitReplace {
                
                for replace in firstDigitReplace {
                    
                    if phone.digits.first == replace.from {
                        
                        phone.replaceSubrange(...phone.startIndex, with: replace.to)
                    }
                }
            }
            
            let limit = limit ?? phone.count
            let limitedPhone = String(phone.prefix(limit))
            let phoneFormatted = phoneFormatter.partialFormatter("+\(limitedPhone)")
            return phoneFormatted
            
        } else {
            
            guard update.isEmpty == false else {
                return nil
            }
            
            return update
        }
    }
    
    private func makeToolbar(toolbarViewModel: ToolbarViewModel, context: Context) -> UIToolbar? {
        
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


