//
//  TextFieldToolbarViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 20.06.2022.
//

import SwiftUI
import Combine

extension TextFieldToolbarView {

    class ViewModel: ObservableObject {

        @Published var text: String
        var bindings = Set<AnyCancellable>()

        let doneButton: ButtonViewModel
        let closeButton: ButtonViewModel

        class ButtonViewModel: ObservableObject {

            @Published var isEnabled: Bool
            let action: () -> Void

            init(isEnabled: Bool, action: @escaping () -> Void) {

                self.isEnabled = isEnabled
                self.action = action
            }
        }

        init(text: String, doneButton: ButtonViewModel, closeButton: ButtonViewModel) {

            self.text = text
            self.doneButton = doneButton
            self.closeButton = closeButton
        }
    }
}

// MARK: - View

struct TextFieldToolbarView: UIViewRepresentable {

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

            guard let text = textField.text else {
                return false
            }

            var filterred = text.filterred()

            if string.isEmpty && filterred.count > 0 {

                guard let stringRange = Range(range, in: text) else {
                    return false
                }

                filterred = text.replacingCharacters(in: stringRange, with: string)
            }

            viewModel.text = "\(filterred)\(string)".filterred()

            return true
        }

        @objc func handleDoneAction() {

            viewModel.doneButton.action()
        }

        @objc func handleCloseAction() {

            viewModel.closeButton.action()
        }
    }

    private func makeToolbar(context: Context) -> UIToolbar {

        let toolbar = UIToolbar()

        let coordinator = context.coordinator
        let color: UIColor = .init(hexString: "#1C1C1C")
        let font: UIFont = .systemFont(ofSize: 18, weight: .bold)

        let doneButton = UIBarButtonItem(title: "Готово", style: .plain, target: coordinator, action: #selector(coordinator.handleDoneAction))
        doneButton.setTitleTextAttributes([.font: font], for: .normal)
        doneButton.tintColor = color

        coordinator.viewModel.doneButton.$isEnabled
            .receive(on: DispatchQueue.main)
            .sink { isEnabled in

                doneButton.isEnabled = isEnabled

            }.store(in: &viewModel.bindings)

        let closeButton = UIBarButtonItem( image: .init(named: "Close Button"), style: .plain, target: context.coordinator, action: #selector(context.coordinator.handleCloseAction))
        closeButton.tintColor = color

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.items = [closeButton, flexibleSpace, doneButton]
        toolbar.barStyle = .default
        toolbar.barTintColor = .white.withAlphaComponent(0)
        toolbar.clipsToBounds = true
        toolbar.sizeToFit()

        return toolbar
    }
}
