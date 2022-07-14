//
//  TextFieldViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 14.07.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension TextFieldView {

    class ViewModel: ObservableObject {

        @Published var text: String
        let doneButton: ButtonViewModel

        init(text: String, doneButton: ButtonViewModel) {

            self.text = text
            self.doneButton = doneButton
        }
    }
}

extension TextFieldView {
    
    struct ButtonViewModel {
        
        let title: String
        let tintColor: String
        let action: () -> Void

        init(title: String, tintColor: String = "#1C1C1C", action: @escaping () -> Void) {

            self.title = title
            self.tintColor = tintColor
            self.action = action
        }
    }
}

// MARK: - View

struct TextFieldView: UIViewRepresentable {

    @ObservedObject var viewModel: ViewModel

    private let textField = UITextField()
    private let keyboardType: UIKeyboardType
    private let font: UIFont

    init(viewModel: ViewModel,
         keyboardType: UIKeyboardType = .numberPad,
         font: UIFont = .systemFont(ofSize: 16, weight: .medium)) {

        self.viewModel = viewModel
        self.keyboardType = keyboardType
        self.font = font
    }

    func makeUIView(context: Context) -> UITextField {

        textField.delegate = context.coordinator
        textField.keyboardType = keyboardType
        textField.inputAccessoryView = makeToolbar(context: context)

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {

        uiView.text = viewModel.text
    }

    func makeCoordinator() -> Coordinator {
        
        Coordinator(viewModel: viewModel)
    }

    class Coordinator: NSObject, UITextFieldDelegate {

        @ObservedObject var viewModel: ViewModel

        init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

            return true
        }

        @objc func handleDoneAction() {
            viewModel.doneButton.action()
        }
    }

    private func makeToolbar(context: Context) -> UIToolbar {

        let toolbar = UIToolbar()

        let coordinator = context.coordinator
        let color: UIColor = .init(hexString: viewModel.doneButton.tintColor)
        let font: UIFont = .systemFont(ofSize: 18, weight: .bold)

        let doneButton = UIBarButtonItem(
            title: viewModel.doneButton.title,
            style: .plain,
            target: coordinator,
            action: #selector(coordinator.handleDoneAction))
        
        doneButton.setTitleTextAttributes([.font: font], for: .normal)
        doneButton.tintColor = color

        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil)

        toolbar.items = [flexibleSpace, doneButton]
        toolbar.barStyle = .default
        toolbar.barTintColor = .white.withAlphaComponent(0)
        toolbar.clipsToBounds = true
        toolbar.sizeToFit()

        return toolbar
    }
}
