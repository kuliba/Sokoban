//
//  TextViewPhoneNumberViewComponent.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 24.10.2022.
//

import Foundation
import SwiftUI
import Combine
import UIKitHelpers

extension TextViewPhoneNumberView {
    
    class ViewModel: ObservableObject {
        
        @Published private(set) var text: String?
        @Published var state: State
        let isEditing: CurrentValueSubject<Bool, Never>

        var toolbar: ToolbarViewModel?
        var dismissKeyboard: () -> Void
        var bindings = Set<AnyCancellable>()
        
        let style: Style
        let placeHolder: PlaceHolder
        let filterSymbols: [Character]?
        let countryCodeReplaces: [CountryCodeReplace]?
        
        let phoneNumberFormatter: PhoneNumberFormaterProtocol
        
        var hasValue: Bool { (text != "" && text != nil) ? true : false }

        init(style: Style = .general, text: String? = nil, placeHolder: PlaceHolder, isEditing: Bool = false, state: State = .idle, toolbar: ToolbarViewModel? = nil, filterSymbols: [Character]? = nil, countryCodeReplaces: [CountryCodeReplace] = [], phoneNumberFormatter: PhoneNumberFormaterProtocol = PhoneNumberKitFormater()) {
            
            self.style = style
            self.text = text
            self.placeHolder = placeHolder
            self.isEditing = .init(isEditing)
            self.state = state
            self.toolbar = toolbar
            self.filterSymbols = filterSymbols
            self.countryCodeReplaces = countryCodeReplaces
            self.phoneNumberFormatter = phoneNumberFormatter
            self.dismissKeyboard = {}
        }
        
        convenience init(_ placeHolder: PlaceHolder) {
            
            switch placeHolder {
            case .contacts:
                
                    self.init(placeHolder: placeHolder, filterSymbols: .defaultFilterSymbols, countryCodeReplaces: .russian, phoneNumberFormatter: PhoneNumberKitFormater())
                
            default:
                self.init(placeHolder: placeHolder)
            }
            
            self.toolbar = .init(doneButton: .init(isEnabled: true, action: { [weak self] in self?.dismissKeyboard() }),
                                 closeButton: .init(isEnabled: true, action: { [weak self] in self?.dismissKeyboard() }))
        }
        
        convenience init(style: Style, placeHolder: PlaceHolder) {
            
            switch placeHolder {
            case .phone:
                
                    self.init(style: style, placeHolder: placeHolder, filterSymbols: .defaultFilterSymbols, countryCodeReplaces: .russian)
            
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
        
        func setText(to text: String?) {
            
            if let text {

               shouldChangeTextIn(
                         .init(location: 0, length: self.text?.count ?? 0),
                         replacementText: text
                     )

            } else {

              DispatchQueue.main.async {
                             
                 self.text = nil
              }
            }
         }

        
        func textViewDidBeginEditing() {
            
            DispatchQueue.main.async {
                
                if self.text != nil {
                    
                    self.state = .editing
                    
                } else {
                    
                    self.state = .selected
                }
                
                self.isEditing.value = true
            }
        }
        
        func state(for text: String?) -> TextViewPhoneNumberView.ViewModel.State {
            
            if text != nil {
                
                return .editing
                
            } else {
                
                return .selected
            }
        }
        
        func textViewDidEndEditing() {
            
            DispatchQueue.main.async {
                
                self.state = .idle
                self.isEditing.value = false
            }
        }
        
        @discardableResult
        func shouldChangeTextIn(
            _ range: NSRange,
            replacementText text: String
        ) -> Bool {
            
            let updated: String?
            
            switch style {
            case .order:
                updated = TextViewPhoneNumberView.updateMasked(value: self.text, inRange: range, update: text, countryCodeReplaces: countryCodeReplaces, phoneFormatter: phoneNumberFormatter, filterSymbols: filterSymbols)
                    
            case .banks:
                updated = self.text.updateMasked(inRange: range, update: text, limit: nil, style: .default)
                
            case .abroad:
                updated = self.text.updateMasked(inRange: range, update: text, limit: nil, style: .default).filter(\.isLetter)
                
            case .payments:
                updated = TextViewPhoneNumberView.updateMasked(value: self.text, inRange: range, update: text, countryCodeReplaces: countryCodeReplaces, phoneFormatter: phoneNumberFormatter, filterSymbols: filterSymbols)
                
            default:
                updated = self.text.updateMasked(inRange: range, update: text, limit: nil, style: .default)
            }
            
            DispatchQueue.main.async {
                
                self.text = updated
            }
            
            self.isEditing.send(true)
            
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
        
        enum PlaceHolder: Equatable {
            
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

struct TextViewPhoneNumberView: UIViewRepresentable {
    
    @ObservedObject var viewModel: TextViewPhoneNumberView.ViewModel
    
    var font: UIFont = .systemFont(ofSize: 19, weight: .regular)
    var backgroundColor: Color = .clear
    var textColor: Color = .black
    var tintColor: Color = .black
    
    func makeUIView(context: Context) -> UITextView {
        
        let textView = WrappedTextView()
        switch viewModel.style {
        case .payments:
            textView.font = .init(name: "Inter-Medium", size: 16.0)
            
        case .order:
            textView.font = .init(name: "Inter", size: 16)
            
        default:
            textView.font = font
        }
        
        textView.backgroundColor = backgroundColor.uiColor()
        textView.tintColor = tintColor.uiColor()
        render(textView)

        textView.delegate = context.coordinator
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        textView.keyboardType = viewModel.style.keyboardType
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        
        viewModel.dismissKeyboard = { textView.resignFirstResponder() }
        
        if let toolbarViewModel = viewModel.toolbar {
            
            textView.inputAccessoryView = makeToolbar(toolbarViewModel: toolbarViewModel, context: context)
        }
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        
        render(textView)
    }
    
    func render(_ textView: UITextView) {
        
        if viewModel.hasValue {
            
            textView.text = viewModel.text
            textView.textColor = textColor.uiColor()
            
        } else {
            
            if viewModel.state == .idle {
                
                textView.text = viewModel.placeHolder.title
                
            } else {
                
                textView.text = ""
            }
            
            textView.textColor = .lightGray
        }
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
            
            viewModel.textViewDidBeginEditing()
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            
            viewModel.textViewDidEndEditing()
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            
            return viewModel.shouldChangeTextIn(range, replacementText: text)
        }
        
        @objc func handleDoneAction() {
            viewModel.toolbar?.doneButton.action()
        }
        
        @objc func handleCloseAction() {
            viewModel.toolbar?.closeButton?.action()
        }
    }
    
#warning("Hardcoded phoneMaxLength in `limit` parameter default value. Need to replace with data from the backend.")
    static func updateMasked(value: String?, inRange: NSRange, update: String, countryCodeReplaces: [CountryCodeReplace]?, phoneFormatter: PhoneNumberFormaterProtocol, filterSymbols: [Character]?, limit: Int? = 18) -> String? {
        
        let valueUnwraped = value ?? update
        let didAddToValidPhone = phoneFormatter.isValid(valueUnwraped) && inRange.length == 0
        
        guard !didAddToValidPhone else {
            return valueUnwraped
        }
        
        var updatedValue = valueUnwraped
        let rangeStart = valueUnwraped.index(valueUnwraped.startIndex, offsetBy: inRange.lowerBound)
        let rangeEnd = valueUnwraped.index(valueUnwraped.startIndex, offsetBy: inRange.upperBound)
        
        if value != nil {
            
            updatedValue.replaceSubrange(rangeStart..<rangeEnd, with: update)
        }
        
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
            
            return filteredValue.isEmpty ? nil : valueUnwraped
        }
        
        var phone = updatedValue.digits
        
        if let countryCodeReplaces = countryCodeReplaces,
           phone.count <= 2,
           (!update.isEmpty || inRange == NSRange(location: 0, length: 0)) {
            
            phone = replaceDigits(phone: updatedValue.digits, countryCodeReplaces: countryCodeReplaces)
        }
        
        let limit = limit ?? phone.count
        let limitedPhone = String(phone.prefix(limit))
        let phoneFormatted = phoneFormatter.partialFormatter("+\(limitedPhone)")
        
        return phoneFormatted
    }
    
    static func replaceDigits(phone: String, countryCodeReplaces: [CountryCodeReplace]) -> String {
        
        var phone = phone.digits
        
        for replace in countryCodeReplaces {
            
            let from = replace.from.description
            
            if phone.hasPrefix(from),
               !phone.hasPrefix(replace.to),
               let range = phone.range(of: from)
            {
                phone.replaceSubrange(range, with: replace.to)
            }
        }
        
        return phone
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

//MARK: Helpers

extension [Character] {
    
    static let defaultFilterSymbols: [Character] = ["-", "(", ")", "+"]
    
}

extension TextViewPhoneNumberView.ViewModel.Style {
    
    var keyboardType: UIKeyboardType {
        
        switch self {
        case .general, .banks, .abroad:
            return .default
            
        case .payments:
            return .phonePad
        
        case .order:
            return .decimalPad
        }
    }
}
