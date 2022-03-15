//
//  TextFieldMaskableViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 16.02.2022.
//

import Foundation
import SwiftUI

//MARK: - ViewModel

extension TextFieldMaskableView {
    
    class ViewModel: ObservableObject {
        
        let masks: [StringValueMask]
        let regExp: String
        @Published var text: String?
        @Published var isEnabled: Bool
        var dismissKeyboard: () -> Void
        
        internal init(masks: [StringValueMask], regExp: String, text: String? = nil, isEnabled: Bool = true) {
            
            self.masks = masks
            self.regExp = regExp
            self.text = text
            self.isEnabled = isEnabled
            self.dismissKeyboard = {}
        }
    }
}

//MARK: - View

struct TextFieldMaskableView: UIViewRepresentable {
    
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
        
        Coordinator(masks: viewModel.masks, regExp: viewModel.regExp, text: $viewModel.text)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        let masks: [StringValueMask]
        let regExp: String
        var text: Binding<String?>
        
        init(masks: [StringValueMask], regExp: String, text: Binding<String?>) {
            
            self.masks = masks
            self.regExp = regExp
            self.text = text
        }
        
        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

            textField.text = TextFieldMaskableView.updateMasked(value: textField.text, inRange: range, update: string, masks: masks, regExp: regExp)
            text.wrappedValue = textField.text
            
            return false
        }
    }
    
    /// Updates masked string value with string update, replacing characters in ramge, and format result string with one of masks
    /// - Parameters:
    ///   - value: masked string value, for example: `1234 5678 89`
    ///   - inRange: characters range required to replace
    ///   - update: any string, expample: `kl;ja 32874 ;ajkdj`
    ///   - masks: masks array, one of them must be applyed
    ///   - regExp: regular expression string required to filter update string
    /// - Returns: masked string result, example: `1234 5678 892`
    static func updateMasked(value: String?, inRange: NSRange, update: String,  masks: [StringValueMask], regExp: String) -> String? {

        // filter update from unexpected synbols
        let filteredUpdate = (try? update.filterred(regEx: regExp)) ?? update
        
        if let value = value {
            
            // replace value characters with filterred update characters in given range
            var updatedValue = value
            let rangeStart = value.index(value.startIndex, offsetBy: inRange.lowerBound)
            let rangeEnd = value.index(value.startIndex, offsetBy: inRange.upperBound)
            updatedValue.replaceSubrange(rangeStart..<rangeEnd, with: filteredUpdate)
            
            // return updated value if masks array empty
            guard masks.isEmpty == false else {
                return updatedValue
            }
            
            // remove mask from value
            let filterredValue = (try? updatedValue.filterred(regEx: regExp)) ?? updatedValue
            let masked = filterredValue.masked(masks: masks)
            
            return masked.count > 0 ? masked : nil
            
        } else {
            
            // return filterred value if masks array empty
            guard masks.isEmpty == false else {
                return filteredUpdate
            }
            let masked = filteredUpdate.masked(masks: masks)
            
            return masked.count > 0 ? masked : nil
        }
    }
}

