//
//  TextFieldFormatableViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 17.03.2022.
//

import Foundation
import SwiftUI

//MARK: - ViewModel

extension TextFieldFormatableView {
    
    class ViewModel: ObservableObject {
        
        @Published var formatter: NumberFormatter
        @Published var text: String?
        @Published var isEnabled: Bool
        var dismissKeyboard: () -> Void
        
        var value: Double {
            
            guard let text = text, let value = formatter.number(from: text) else {
                return 0
            }
            
            return value.doubleValue
        }
        
        internal init(value: Double, formatter: NumberFormatter, isEnabled: Bool = true) {
            
            self.formatter = formatter
            self.text = formatter.string(from: NSNumber(value: value))
            self.isEnabled = isEnabled
            self.dismissKeyboard = {}
        }
    }
}

//MARK: - View

struct TextFieldFormatableView: UIViewRepresentable {
    
    @ObservedObject var viewModel: ViewModel
    
    //TODO: wrapper Font -> UIFont required
    var font: UIFont = .monospacedSystemFont(ofSize: 19, weight: .regular)
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
 
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        
        uiView.text = viewModel.text
        uiView.isUserInteractionEnabled = viewModel.isEnabled
    }
    
    func makeCoordinator() -> Coordinator {
        
        Coordinator(text: $viewModel.text, formatter: viewModel.formatter)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        var text: Binding<String?>
        var formatter: NumberFormatter
        
        init(text: Binding<String?>, formatter: NumberFormatter) {
            
            self.text = text
            self.formatter = formatter
        }
        
        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

            textField.text = TextFieldFormatableView.updateFormatted(value: textField.text, inRange: range, update: string, formatter: formatter)
            text.wrappedValue = textField.text
            
            return false
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
    static func updateFormatted(value: String?, inRange: NSRange, update: String, formatter: NumberFormatter) -> String? {
        
        let expectedCharacters = "0123456789.,"

        if let value = value {
            
            let originalValueRangeUpperBound = value.count
            
            // remove formatting from value, example: `1 234,56 ₽` -> `1234,56`
            let valueUnformatted = value.filter{ expectedCharacters.contains($0) }
            
            // offset for inRange lower and upper bounds
            let rangeOffset = originalValueRangeUpperBound - valueUnformatted.count
            
            var updatedValue = valueUnformatted
            let rangeStart = value.index(valueUnformatted.startIndex, offsetBy: inRange.lowerBound - rangeOffset)
            let rangeEnd = value.index(valueUnformatted.startIndex, offsetBy: inRange.upperBound - rangeOffset)
            
            // apply update to value in range
            updatedValue.replaceSubrange(rangeStart..<rangeEnd, with: update)
                        
            // filter only expected characters
            let filterredUpdate = updatedValue.filter{ expectedCharacters.contains($0) }.replacingOccurrences(of: formatter.decimalSeparator, with: ".")
            
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
}
