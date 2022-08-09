//
//  TextFieldFormatableViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 17.03.2022.
//

import Foundation
import SwiftUI
import Combine

//MARK: - ViewModel

extension TextFieldFormatableView {
    
    class ViewModel: ObservableObject {
        
        @Published var formatter: NumberFormatter
        @Published var text: String?
        @Published var isEnabled: Bool
        @Published var isEditing: Bool
        @Published var limit: Int?
        
        let type: Kind
        let toolbar: ToolbarViewModel?
        var dismissKeyboard: () -> Void
        
        var bindings = Set<AnyCancellable>()
        
        var value: Double {
            
            guard let text = text, let value = formatter.number(from: text) else {
                return 0
            }
            
            return value.doubleValue
        }
        
        enum Kind {
            
            case general
            case currencyWallet
        }
        
        internal init(type: Kind = .general, value: Double, formatter: NumberFormatter, isEnabled: Bool = true, isEditing: Bool = false, limit: Int? = nil, toolbar: ToolbarViewModel? = nil) {
            
            self.type = type
            self.formatter = formatter
            self.text = formatter.string(from: NSNumber(value: value))
            self.isEnabled = isEnabled
            self.isEditing = isEditing
            self.limit = limit
            self.toolbar = toolbar
            self.dismissKeyboard = {}
        }
    }
}

extension TextFieldFormatableView {
    
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

struct TextFieldFormatableView: UIViewRepresentable {
    
    @ObservedObject var viewModel: ViewModel
    
    //TODO: wrapper Font -> UIFont required
    var font: UIFont = .systemFont(ofSize: 19, weight: .regular)
    var backgroundColor: Color = .clear
    var textColor: Color = .white
    var tintColor: Color = .white
    var keyboardType: UIKeyboardType = .numberPad
    
    private let textField = UITextField()
    
    func makeUIView(context: Context) -> UITextField {
        
        textField.delegate = context.coordinator
        textField.font = font
        textField.backgroundColor = backgroundColor.uiColor()
        textField.textColor = textColor.uiColor()
        textField.tintColor = tintColor.uiColor()
        textField.keyboardType = keyboardType
        
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
        
        Coordinator(viewModel: viewModel, text: $viewModel.text, formatter: viewModel.formatter, limit: viewModel.limit)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        @ObservedObject var viewModel: ViewModel
        
        var text: Binding<String?>
        var formatter: NumberFormatter
        var limit: Int?
        
        init(viewModel: ViewModel, text: Binding<String?>, formatter: NumberFormatter, limit: Int?) {
            
            self.viewModel = viewModel
            self.text = text
            self.formatter = formatter
            self.limit = limit
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            
            switch viewModel.type {
            case .general:
                updateCursorPosition(textField)
            default: break
            }
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            viewModel.isEditing = true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            viewModel.isEditing = false
        }
        
        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            switch viewModel.type {
            case .general:
                
                textField.text = TextFieldFormatableView.updateFormatted(value: textField.text, inRange: range, update: string, formatter: formatter, limit: limit)
                text.wrappedValue = textField.text
                updateCursorPosition(textField)
                
            case .currencyWallet:
                
                textField.text = TextFieldFormatableView.updateFormatted(value: textField.text, inRange: range, update: string, formatter: formatter, limit: limit)
                text.wrappedValue = textField.text
            }
            
            return false
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
    
    /// Updates masked string value with string update, replacing characters in ramge, and format result string with one of masks
    /// - Parameters:
    ///   - value: formatted string value, for example: `1234 ₽`
    ///   - inRange: characters range required to replace
    ///   - update: any string, expample: `kl;ja 32874 ;ajkdj`
    ///   - formatter: number formatter must be applyed
    ///   - regExp: regular expression string required to filter update string
    /// - Returns: formatted string result, example: `1 234.56 ₽`
    static func updateFormatted(value: String?, inRange: NSRange, update: String, formatter: NumberFormatter, limit: Int? = nil) -> String? {
        
        let expectedCharacters = "0123456789.,"
        
        if let value = value {
            
            let rangeStart = value.index(value.startIndex, offsetBy: inRange.lowerBound)
            let rangeEnd = value.index(value.startIndex, offsetBy: inRange.upperBound)
            
            var updatedValue = value
            
            // apply update to value in range
            updatedValue.replaceSubrange(rangeStart..<rangeEnd, with: update)
            
            let semicolon = updatedValue.filter { ".,".contains($0) }
            
            // number dots and commas is not more than one
            if semicolon.count > 1 {
                return value
            }
            
            // remove formatting from value, example: `1 234,56 ₽` -> `1234,56`
            updatedValue = updatedValue.filter{ expectedCharacters.contains($0) }
            
            // filter only expected characters
            let filterredUpdate = updatedValue.filter{ expectedCharacters.contains($0) }.replacingOccurrences(of: formatter.decimalSeparator, with: ".")
            
            // check limit
            if let limit = limit, limit > 0 {
                
                if filterredUpdate.contains(".") == true {
                    
                    let separated = filterredUpdate.split(separator: ".")
                    if separated[0].count > limit, separated.count > 1 {
                        
                        return value
                    }
                    
                } else {
                    
                    if updatedValue.count > limit {
                        
                        return value
                    }
                }
            }
            
            // crop to max fraction digits, example: `1234.567` -> `1234.56`
            let filterredUpdateSplitted = filterredUpdate.split(separator: ".")
            var filterredUpdateFixed = ""
            for (index, chunk) in filterredUpdateSplitted.enumerated() {
                
                switch index {
                case 0: filterredUpdateFixed += chunk
                case 1: filterredUpdateFixed += ".\(chunk.prefix(formatter.maximumFractionDigits))"
                default: break
                }
            }
            
            // try convert updated value into double
            guard let doubleValue = filterredUpdateFixed == "" ? 0 : Double(filterredUpdateFixed) else {
                return value
            }
            
            // check if last character is decimal separator, example: `1234.`
            if let lastCharacter = filterredUpdate.last, String(lastCharacter) == "." {
                
                // temp add to doubleValue 0.1, example: `1234` -> `1234.1`
                let doubleValueTemp = doubleValue + 0.1
                
                // format temp double value, example: `1234.1` -> `1 234,1 ₽`
                let formattedValue = formatter.string(from: NSNumber(value: doubleValueTemp))
                
                // remove temp fraction value and return, example: `1 234,1 ₽` -> `1 234, ₽`
                let replaceString = formatter.decimalSeparator + "1"
                return formattedValue?.replacingOccurrences(of: replaceString, with: formatter.decimalSeparator)
                
            } else {
                
                // return formatted double value, example: `1234.56` -> `1 234,56 ₽`
                return formatter.string(from: NSNumber(value: doubleValue))
            }
            
        } else {
            
            // filter update from unexpected symbols
            let filteredUpdate = update.filter{ expectedCharacters.contains($0) }
            
            // try convert update value into double
            guard let doubleValue = Double(filteredUpdate) else {
                return value
            }
            
            // return formatted double value, example: `1234.56` -> `1 234,56 ₽`
            return formatter.string(from: NSNumber(value: doubleValue))
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
