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
        let toolbar: ToolbarViewModel?
        
        internal init(masks: [StringValueMask], regExp: String, text: String? = nil, isEnabled: Bool = true, toolbar: ToolbarViewModel?) {
            
            self.masks = masks
            self.regExp = regExp
            self.text = text
            self.isEnabled = isEnabled
            self.dismissKeyboard = {}
            self.toolbar = toolbar
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
        textField.keyboardType = keyboardType
            
        textField.textColor = textColor.uiColor()
        textField.tintColor = tintColor.uiColor()
        
        viewModel.dismissKeyboard = { textField.resignFirstResponder() }
 
        if let toolbarViewModel = viewModel.toolbar {
            
            textField.inputAccessoryView = makeToolbar(coordinator: context.coordinator, toolbarViewModel: toolbarViewModel)
        }
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        
        uiView.text = viewModel.text
        uiView.isUserInteractionEnabled = viewModel.isEnabled
    }
    
    func makeCoordinator() -> Coordinator {
        
        Coordinator(viewModel: viewModel, masks: viewModel.masks, regExp: viewModel.regExp, text: $viewModel.text)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        let viewModel: ViewModel
        let masks: [StringValueMask]
        let regExp: String
        var text: Binding<String?>
        
        init(viewModel: ViewModel, masks: [StringValueMask], regExp: String, text: Binding<String?>) {
            
            self.viewModel = viewModel
            self.masks = masks
            self.regExp = regExp
            self.text = text
        }
        
        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

            textField.text = TextFieldMaskableView.updateMasked(value: textField.text, inRange: range, update: string, masks: masks, regExp: regExp)
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
            
            // apply mask to result value
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
    
    private func makeToolbar(coordinator: Coordinator, toolbarViewModel: ToolbarViewModel) -> UIToolbar {
        
        let toolbar = UIToolbar(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        let color: UIColor = Color.textSecondary.uiColor()
        let font: UIFont = .systemFont(ofSize: 18, weight: .bold)
        
        let doneButton = UIBarButtonItem(title: "Готово", style: .plain, target: coordinator, action: #selector(coordinator.handleDoneAction))
        doneButton.setTitleTextAttributes([.font: font], for: .normal)
        doneButton.tintColor = color
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var items: [UIBarButtonItem] = [flexibleSpace, doneButton]
        
        if toolbarViewModel.closeButton != nil {
            
            let closeButton = UIBarButtonItem(image: .init(named: "Close Button"), style: .plain, target: coordinator, action: #selector(coordinator.handleCloseAction))
            closeButton.tintColor = color
            
            items.insert(closeButton, at: 0)
        }
        
        toolbar.items = items
        toolbar.barStyle = .default
        toolbar.barTintColor = .white.withAlphaComponent(0)
        toolbar.clipsToBounds = true
        
        return toolbar
    }
}

