//
//  PaymentsInputViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.02.2022.
//

import SwiftUI
import Combine
import TextFieldComponent

//MARK: - ViewModel

extension PaymentsInputView {
    
    class ViewModel: PaymentsParameterViewModel, PaymentsParameterViewModelWarnable, ObservableObject {
        
        let icon: Image?
        @Published var title: String?
        let textField: RegularFieldViewModel
        @Published var additionalButton: ButtonViewModel?
        @Published var warning: String?
        @Published var info: String?
        
        private static let iconPlaceholder = Image.ic24File
        
        var parameterInput: Payments.ParameterInput? { source as? Payments.ParameterInput }

        init(icon: Image? = nil, title: String? = nil, textField: RegularFieldViewModel, additionalButton: ButtonViewModel? = nil, warning: String? = nil, info: String? = nil, source: PaymentsParameterRepresentable) {
            
            self.icon = icon
            self.title = title
            self.textField = textField
            self.additionalButton = additionalButton
            self.warning = warning
            self.info = info
            super.init(source: source)
        }
        
        convenience init(with parameterInput: Payments.ParameterInput) {
            
            let textField = TextFieldFactory.makeTextField(
                text: parameterInput.parameter.value,
                placeholderText: parameterInput.title,
                keyboardType: parameterInput.inputType.keyboardType,
                limit: parameterInput.limitator?.limit
            )
            
            let additionalButton: ButtonViewModel? = {
                
                switch parameterInput.info {
                case .some:
                    return .init(icon: Image.ic24Info, action: {})
                    
                case .none:
                    return nil
                }
            }()
            
            let title: String? = {
               
                switch parameterInput.value {
                case .some(""), .none:
                    return nil
                    
                case .some:
                    return parameterInput.title
                }
            }()
            
            self.init(icon: parameterInput.icon?.image, title: title, textField: textField, additionalButton: additionalButton, source: parameterInput)
            
            // this update requiered for cases where intial value == ""
            update(value: parameterInput.value)
            bind()
        }
        
        //MARK: - Overrides
        
        override var isValid: Bool { parameterInput?.validator.isValid(value: value.current) ?? false }
        
        override func update(value: String?) {
            
            switch value {
            case .some(""), .none:
                super.update(value: nil)
                
            case .some:
                super.update(value: value)
            }
        }
        
        override func update(source: PaymentsParameterRepresentable) {
            super.update(source: source)
            
            textField.setText(to: source.value)
            
            withAnimation {
                
                additionalButton = parameterInput?.hint.map { hint in
                    
                        .init(
                            icon: Image.ic24Info,
                            action: { [weak self] in
                                
                                self?.action.send(PaymentsParameterViewModelAction.Hint.Show(viewModel: .init(hintData: hint)))
                            }
                        )
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
        
        textField.$state
            .dropFirst()
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                
                update(value: state.text)

                withAnimation {
                    updateTitle(textFieldState: state)
                    updateWarning(isEditing: state.isEditing)
                }
            }
            .store(in: &bindings)
    }
    
    private func updateTitle(textFieldState: TextFieldState) {

        switch textFieldState {
        case .placeholder:
            title = nil
            
        default:
            title = parameterInput?.title
        }
    }
    
    private func updateWarning(isEditing: Bool) {
        
        if isEditing {
            
            warning = nil
            
        } else {
            
            if let parameterInput = parameterInput,
               let action = parameterInput.validator.action(with: value.current, for: .post),
               case let .warning(message) = action {
                
                warning = message
                
            } else {
                
                warning = nil
            }
        }
    }
    
    //TODO: add tests
    var displayTitle: String? {
        
        if isEditable {
            
            return title
        } else {
            
            return parameterInput?.title ?? ""
        }
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

//MARK: - Private extensions

extension Payments.ParameterInput.InputType {
    
    var keyboardType: KeyboardType {
        
        switch self {
        case .default: return .default
        case .number: return .number
        }
    }
}

// MARK: - View

struct PaymentsInputView: View {
    
    @ObservedObject var viewModel: PaymentsInputView.ViewModel
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 16) {

            iconView
                .frame(width: 24, height: 24)
                .padding(.top, iconTopPadding)

            content
                .padding(.trailing, 16)
            
            Spacer()

            additionalButton
                .frame(width: 24, height: 24)
                .padding(.top, iconTopPadding)
        }
        .padding(.horizontal, 16)
        .padding(.top, 13)
        .padding(.bottom, 7)
    }
    
    private var iconTopPadding: CGFloat {
        
        switch viewModel.title {
        case .some: return 11
        case .none: return 5
        }
    }
    
    private var content: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            VStack(alignment: .leading, spacing: 0) {
                
                titleView
                
                textFiled
            }

            infoView
                .padding(.bottom, 8)
            
            warningView
                .padding(.bottom, 8)
        }
    }
    
    @ViewBuilder
    private var iconView: some View {
        
        if let icon = viewModel.icon {
            
            icon
                .resizable()
                .renderingMode(.original)
                .foregroundColor(.mainColorsGray)
                .accessibilityIdentifier("PaymentsInputIcon")
            
        } else {
            
            Color.clear
        }
    }
    
    @ViewBuilder
    private var titleView: some View {
        
        viewModel.displayTitle.map {
            
            Text($0)
                .font(.textBodyMR14180())
                .foregroundColor(.textPlaceholder)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    )
                )
                .accessibilityIdentifier("PaymentsInputTitle")
        }
    }
    
    @ViewBuilder
    private var textFiled: some View {
        
        if viewModel.isEditable {
            
            RegularTextFieldView(
                viewModel: viewModel.textField,
                font: .systemFont(ofSize: 16),
                textColor: .textSecondary
            )
            .accessibilityIdentifier("PaymentsInputTextField")
            
        } else {
            
            viewModel.value.current.map {
                
                Text($0)
                    .font(.textH4M16240())
                    .foregroundColor(.textSecondary)
                    .padding(.vertical, 7)
                    .accessibilityIdentifier("PaymentsInputTextFieldUneditable")
            }
        }
    }
    
    @ViewBuilder
    private var additionalButton: some View {
        
        if viewModel.isEditable,
           let additionalButton = viewModel.additionalButton {
            
            Button(action: additionalButton.action) {
                
                additionalButton.icon
                    .renderingMode(.template)
                    .foregroundColor(.mainColorsGray)
            }
            .accessibilityIdentifier("PaymentsInputAdditionalButton")
        }
    }
    
    @ViewBuilder
    private var infoView: some View {
        
        if let info = viewModel.info {
            
            Text(info)
                .font(.textBodySR12160())
                .foregroundColor(.textPlaceholder)
                .accessibilityIdentifier("PaymentsInputInfoText")
        }
    }
    
    @ViewBuilder
    private var warningView: some View {
        
        if let warning = viewModel.warning {
            
            Text(warning)
                .font(.textBodySR12160())
                .foregroundColor(.systemColorError)
                .accessibilityIdentifier("PaymentsInputWarningText")
        }
    }
}

// MARK: - Preview

struct PaymentsInputView_Previews: PreviewProvider {
    
    private static func preview(_ viewModel: PaymentsGroupViewModel) -> some View {
        PaymentsGroupView(viewModel: viewModel)
    }

    static var previews: some View {
        
        Group {
            
            preview(.init(items: [PaymentsInputView.ViewModel.sampleEmptyValue]))
                .previewDisplayName("Empty Value")
            
            preview(.init(items: [PaymentsInputView.ViewModel.sample]))
                .previewDisplayName("Value")
            
            preview(.init(items: [PaymentsInputView.ViewModel.sampleLongValue]))
                .previewDisplayName("Long Value")
            
            preview(.init(items: [PaymentsInputView.ViewModel.sampleNotEditable]))
                .previewDisplayName("Not Editable")
       
            previewGroup()
        }
    }
    
    private static func previewGroup() -> some View {
        
        Group {

            PaymentsInputView(viewModel: .sampleError)

            paymentsInputView(.sample(value: "123", validator: .minLengthFive))
            paymentsInputView(.sample(value: "123", validator: .minLengthFive, isEditable: false))
        }
    }
    
    private static func paymentsInputView(
        _ parameterInput: Payments.ParameterInput
    ) -> some View {
        
        PaymentsInputView(viewModel: .init(with: parameterInput))
    }
}

// MARK: - Preview Content

extension PaymentsInputView.ViewModel {
    
    static let sampleEmptyValue = PaymentsInputView.ViewModel(with: .sample(value: nil))
    static let sample = PaymentsInputView.ViewModel(with: .sample(info: ""))
    static let sampleLongValue = PaymentsInputView.ViewModel(with: .sample(value: "Длинное, очень длинное значение для проверки того как отрабатывает лейаут", info: ""))
    static let sampleNotEditable = PaymentsInputView.ViewModel(with: .sample(isEditable: false))
    
    static let sampleError = PaymentsInputView.ViewModel(icon: .paymentsInputSample, title: "description", textField: .preview, additionalButton: .init(icon: .ic24Info, action: {}), warning: "Минимальная длинна 5 символов", info: "info", source: Payments.ParameterMock())
}

private extension Payments.ParameterInput {
    
    static func sample(
        value: String? = "0016196314",
        icon: ImageData = .paymentsInputSample,
        title: String = "ИНН подразделения",
        info: String? = nil,
        validator: Payments.Validation.RulesSystem = .anyValue,
        limit: Int? = nil,
        isEditable: Bool = true
    ) -> Self {
        
        .init(
            .init(id: UUID().uuidString, value: value),
            icon: icon,
            title: title,
            info: info,
            validator: validator,
            limitator: limit.map { .init(limit: $0) },
            isEditable: isEditable
        )
    }
}

private extension RegularFieldViewModel {
    
    static let preview = TextFieldFactory.makeTextField(
        text: "123",
        placeholderText: "ИНН подразделения",
        keyboardType: .number,
        limit: nil
    )
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
