//
//  OrderNameViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 12.12.2022.
//

import SwiftUI

// MARK: - ViewModel

extension TextFieldView {
    
    class ViewModel: ObservableObject {
        
        @Published var text: String
        @Published var isEditing: Bool
        @Published var isResend: Bool
        @Published var isError: Bool
        @Published var isUserInteractionEnabled: Bool
        @Published var timer: TimerView.ViewModel?
        
        var becomeFirstResponder: () -> Void
        var resignFirstResponder: () -> Void
        
        let kind: Kind
        
        var isActive: Bool {
           
            if isEditing == true {
                return true
            }
            
            if text.isEmpty == false {
                return true
            }
            
            return false
        }
        
        init(_ text: String = "", isEditing: Bool, isResend: Bool, isError: Bool, kind: Kind, isUserInteractionEnabled: Bool = true, becomeFirstResponder: @escaping () -> Void = {}, resignFirstResponder: @escaping () -> Void = {}) {
            
            self.text = text
            self.isEditing = isEditing
            self.isResend = isResend
            self.isError = isError
            self.kind = kind
            self.isUserInteractionEnabled = isUserInteractionEnabled
            self.becomeFirstResponder = becomeFirstResponder
            self.resignFirstResponder = resignFirstResponder
        }
        
        convenience init(_ kind: Kind) {
            
            self.init(
                isEditing: false,
                isResend: false,
                isError: false,
                kind: kind
            )
        }
        
        func update() {
            
            DispatchQueue.main.async {
                
                self.text = ""
                self.becomeFirstResponder()
            }
        }
    }
}

// MARK: - Types

extension TextFieldView.ViewModel {
    
    var placeholder: String { kind.placeholder }
    var count: Int { kind.count }

    enum Kind {
        
        case name
        case smsCode
        
        var placeholder: String {
            
            switch self {
            case .name: return "Имя"
            case .smsCode: return "Введите код из СМС"
            }
        }
        
        var count: Int {
            
            switch self {
            case .name: return 20
            case .smsCode: return 6
            }
        }
    }
}

// MARK: - View

struct TextFieldView: UIViewRepresentable {
    
    @ObservedObject var viewModel: ViewModel

    private let textField = UITextField()
    
    func makeUIView(context: Context) -> UITextField {
        
        textField.delegate = context.coordinator
        textField.placeholder = viewModel.placeholder
        textField.font = .init(name: "Inter", size: 16)
        textField.textColor = .init(hex: "#999999")
        textField.backgroundColor = .init(hex: "#F6F6F7")
        textField.inputAccessoryView = makeToolbar(context: context)
        textField.autocorrectionType = .no
        
        viewModel.becomeFirstResponder = { textField.becomeFirstResponder() }
        viewModel.resignFirstResponder = { textField.resignFirstResponder() }
        
        switch viewModel.kind {
        case .name: textField.keyboardType = .namePhonePad
        case .smsCode: textField.keyboardType = .numberPad
        }
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        
        uiView.text = viewModel.text
    }
    
    func makeCoordinator() -> Coordinator {
        
        Coordinator(viewModel)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        @ObservedObject var viewModel: ViewModel
        
        init(_ viewModel: ViewModel) {
            
            self.viewModel = viewModel
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {

            textField.placeholder = nil
            viewModel.isEditing = true
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            
            guard let text = textField.text else {
                return
            }
            
            switch text.isEmpty {
            case true:
                textField.placeholder = viewModel.placeholder
            case false:
                textField.text = viewModel.text
            }

            viewModel.isEditing = false
        }
        
        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            guard let text = textField.text else {
                return false
            }

            if string.count > 0, text.count == viewModel.count {
                return false
            }

            if string.isEmpty == true {
                
                guard let stringRange = Range(range, in: text) else {
                    return false
                }
                
                viewModel.text = text.replacingCharacters(in: stringRange, with: string)
            
            } else {
                
                viewModel.text = "\(text)\(string)"
            }
            
            return true
        }
        
        @objc func handleDoneAction() {
            UIApplication.shared.endEditing()
        }
    }
    
    private func makeToolbar(context: Context) -> UIToolbar? {
        
        let toolbar = UIToolbar()
        let color: UIColor = .init(hexString: "#1C1C1C")
        let font: UIFont = .systemFont(ofSize: 18, weight: .bold)
        
        let doneButton = UIBarButtonItem(title: "Готово", style: .plain, target: context.coordinator, action: #selector(context.coordinator.handleDoneAction))
        doneButton.setTitleTextAttributes([.font: font], for: .normal)
        doneButton.tintColor = color

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let items: [UIBarButtonItem] = [flexibleSpace, doneButton]
        
        toolbar.items = items
        toolbar.barStyle = .default
        toolbar.barTintColor = .white.withAlphaComponent(0)
        toolbar.clipsToBounds = true
        toolbar.sizeToFit()
        
        return toolbar
    }
}

// MARK: - Preview

struct TextFieldView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TextFieldView(viewModel: .init(.name))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
