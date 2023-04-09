//
//  PaymentsInputViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension PaymentsInputView {
    
    class ViewModel: PaymentsParameterViewModel, PaymentsParameterViewModelWarnable, ObservableObject {
        
        let icon: Image?
        let description: String
        let textField: TextFieldRegularView.ViewModel
        
        @Published var title: String?
        @Published var additionalButton: ButtonViewModel?
        @Published var warning: String?
        @Published var info: String?
        
        private let model: Model
        private static let iconPlaceholder = Image.ic24File
        
        var parameterInput: Payments.ParameterInput? { source as? Payments.ParameterInput }
        override var isValid: Bool { parameterInput?.validator.isValid(value: value.current) ?? false }
        
        init(icon: Image?, description: String, content: String, info: String? = nil, warning: String? = nil, textField: TextFieldRegularView.ViewModel, additionalButton: ButtonViewModel? = nil, model: Model = .emptyMock, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.icon = icon
            self.description = description
            self.info = info
            self.warning = warning
            self.additionalButton = additionalButton
            self.model = model
            self.textField = textField
            
            super.init(source: source)
        }
        
        convenience init(with parameterInput: Payments.ParameterInput, model: Model) {
            
            let icon = parameterInput.icon?.image
            let description = parameterInput.title
            let content = parameterInput.parameter.value ?? ""
            
            var textField: TextFieldRegularView.ViewModel
            switch parameterInput.inputType {
            case .default:
                textField = .init(text: content, placeholder: description, style: .default, limit: parameterInput.limitator?.limit)

            case .number:
                textField = .init(text: content, placeholder: description, style: .number, limit: parameterInput.limitator?.limit)
            }
            
            if parameterInput.hint != nil {
                
                self.init(icon: icon, description: description, content: content, textField: textField, additionalButton: .init(icon: Image.ic24Info, action: {}), model: model, source: parameterInput)
                
            } else {
                
                self.init(icon: icon, description: description, content: content, textField: textField, model: model, source: parameterInput)
            }
            
            bind()
        }
        
        override func update(source: PaymentsParameterRepresentable) {
            super.update(source: source)
            
            textField.setText(to: source.value)
            
            withAnimation {
                
                if let hint = parameterInput?.hint  {
                    
                    additionalButton = .init(icon: Image.ic24Info, action: { [weak self] in
                        
                        self?.action.send(PaymentsParameterViewModelAction.Hint.Show(viewModel: .init(hintData: hint)))
                    })
                    
                } else {
 
                    additionalButton = nil
                }
            }
        }
        
        func update(warning: String) {
            
            withAnimation {
                
                self.warning = warning
            }
        }
        
        override func updateValidationWarnings() {
            
            if isValid == false,
               let parameterInput = parameterInput,
               let action = parameterInput.validator.action(with: value.current, for: .post),
               case .warning(let message) = action {
                
                withAnimation {
                    self.warning = message
                }
            }
        }
    }
}

//MARK: Bindings

extension PaymentsInputView.ViewModel {
    
    private func bind() {
        
        textField.$text
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] content in
                
                if content == "" {
                    
                    update(value: nil)
                    
                } else {
                    
                    update(value: content)
                }
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    
                    title = value.current != nil || textField.isEditing.value == true ? description : nil
                }
                
            }.store(in: &bindings)
        
        textField.isEditing
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isEditing in
                
                if isEditing == true {
                    
                    withAnimation(.easeIn(duration: 0.2)) {
                        
                        self.title = description
                        self.warning = nil
                    }
                    
                } else {
                    
                    self.title = value.current == nil ? nil : description
                    
                    if let parameterInput = parameterInput,
                       let action = parameterInput.validator.action(with: value.current, for: .post),
                       case .warning(let message) = action {
                        
                        withAnimation {
                            self.warning = message
                        }
                        
                    } else {
                        
                        withAnimation {
                            self.warning = nil
                        }
                        
                    }
                }
                
            }.store(in: &bindings)
    }
}

// MARK: - Parameter Actions

extension PaymentsParameterViewModelAction {
    
    enum Hint {
        
        struct Show: Action {
            
            let viewModel: HintViewModel
        }
        
        struct Close: Action {}
    }
}

// MARK: - Sub View Model

extension PaymentsInputView.ViewModel {
    
    struct ButtonViewModel {
        
        let icon: Image
        let action: () -> Void
        
        init(icon: Image, action: @escaping () -> Void) {
            
            self.icon = icon
            self.action = action
        }
    }
}

// MARK: - View

struct PaymentsInputView: View {
    
    @ObservedObject var viewModel: PaymentsInputView.ViewModel
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 0) {
            
            iconView
                .frame(width: 24, height: 24)
                .frame(width: 56, height: 48)
            
            vStack
                .padding(.trailing, 16)
        }
        .padding(.vertical, 13)
    }
    
    private var vStack: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            titleView
            
            textFiled
            
            additionalButton
            
            infoView
            
            warningView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private var iconView: some View {
        
        if let icon = viewModel.icon {
            
            icon
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.mainColorsGray)
            
        } else {
            
            Color.clear
                .padding(.leading, 4)
        }
    }
    
    @ViewBuilder
    private var titleView: some View {
        
        if let title = viewModel.title {
            
            Text(title)
                .font(.textBodyMR14180())
                .foregroundColor(.textPlaceholder)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    )
                )
        }
    }
    
    @ViewBuilder
    private var textFiled: some View {
        
        if viewModel.isEditable == true {
            
            TextFieldRegularView(
                viewModel: viewModel.textField,
                font: .systemFont(ofSize: 16)
            )
            .frame(minWidth: 24)
            
        } else {
            
            Text(viewModel.value.current ?? "")
                .foregroundColor(.textSecondary)
                .font(.textBodyMM14200())
        }
    }
    
    @ViewBuilder
    private var additionalButton: some View {
        
        if viewModel.isEditable,
           let additionalButton = viewModel.additionalButton {
            
            Button(action: additionalButton.action) {
                
                additionalButton.icon
                    .foregroundColor(.mainColorsGray)
            }
        }
    }
    
    @ViewBuilder
    private var infoView: some View {
        
        if let info = viewModel.info {
            
            Text(info)
                .font(.textBodySR12160())
                .foregroundColor(.textPlaceholder)
        }
    }
    
    @ViewBuilder
    private var warningView: some View {
        
        if let warning = viewModel.warning {
            
            Text(warning)
                .font(.textBodySR12160())
                .foregroundColor(.systemColorError)
        }
    }
}

// MARK: - Preview

struct PaymentsInputView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            previewGroup()
            
            VStack(content: previewGroup)
                .previewDisplayName("Xcode 14")
                .previewLayout(.sizeThatFits)
        }
    }
    
    private static func previewGroup() -> some View {
        
        Group {
            
            paymentsInputView(.sample(value: nil))
            paymentsInputView(.sample())
            paymentsInputView(.sample(isEditable: false))
            
            paymentsInputView(.sample(value: "+9 925 555-5555", icon: .ic24Smartphone, title: "Номер телефона получателя", isEditable: false))
            paymentsInputView(.sample(value: "123", validator: .minLengthFive))
            PaymentsInputView(viewModel: .sampleError)

            paymentsInputView(.sample(value: "123", validator: .minLengthFive))
            paymentsInputView(.sample(value: "123", validator: .minLengthFive, isEditable: false))
            paymentsInputView(.sample(value: "123", validator: .minLengthFive))
            paymentsInputView(.sample(value: "123", validator: .minLengthFive, isEditable: false))
        }
    }
    
    private static func paymentsInputView(
        _ parameterInput: Payments.ParameterInput
    ) -> some View {
        
        PaymentsInputView(viewModel: .init(with: parameterInput, model: .emptyMock))
    }
}

// MARK: - Preview Content

extension PaymentsInputView.ViewModel {
    
    static let sampleError = PaymentsInputView.ViewModel(icon: .paymentsInputSample, description: "description", content: "123", info: "info", warning: "Минимальная длинна 5 символов", textField: .preview, additionalButton: nil, model: .emptyMock)
}

private extension Payments.ParameterInput {
    
    static func sample(
        value: String? = "0016196314",
        icon: ImageData = .paymentsInputSample,
        title: String = "ИНН подразделения",
        validator: Payments.Validation.RulesSystem = .anyValue,
        limit: Int? = nil,
        isEditable: Bool = true
    ) -> Self {
        
        .init(
            .init(id: UUID().uuidString, value: value),
            icon: icon,
            title: title,
            validator: validator,
            limitator: limit.map { .init(limit: $0) },
            isEditable: isEditable
        )
    }
}

private extension TextFieldRegularView.ViewModel {
    
    static let preview: TextFieldRegularView.ViewModel = .init(text: "123", placeholder: "ИНН подразделения", style: .number, limit: nil)
}

private extension Payments.Validation.RulesSystem {
    
    static let minLengthFive: Self = .init(
        rules: [
            Payments.Validation.MinLengthRule(
                minLenght: 5,
                actions: [.post: .warning("Минимальная длинна 5 символов")]
            )
        ]
    )
}

private extension ImageData {
 
    static let ic24Smartphone: Self = .init(named: "ic24Smartphone")!
    static let paymentsInputSample: Self = .init(with: UIImage(named: "Payments Input Sample")!)!
}

private extension Image {
    
    static let paymentsInputSample: Self = .init(uiImage: UIImage(named: "Payments Input Sample")!)
}
