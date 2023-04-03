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
            
            textField.text = source.value
            
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


//MARK: - Parameter Actions
extension PaymentsParameterViewModelAction {
    
    enum Hint {
        
        struct Show: Action {
            
            let viewModel: HintViewModel
        }
        
        struct Close: Action {}
    }
}

//MARK: - Sub View Model
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

//MARK: - View

struct PaymentsInputView: View {
    
    @ObservedObject var viewModel: PaymentsInputView.ViewModel
    
    var body: some View {
        
        VStack(spacing: 8) {
            
            HStack(spacing: 16) {
                
                if let icon = viewModel.icon {
                    
                    icon
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.mainColorsGray)
                        .frame(width: 24, height: 24)
                    
                } else {
                    
                    Color.clear
                        .frame(width: 24, height: 24)
                        .padding(.leading, 4)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    if let title = viewModel.title {
                        
                        Text(title)
                            .font(.textBodyMR14180())
                            .foregroundColor(.textPlaceholder)
                            .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                    }
                    
                    HStack(spacing: 20) {
                        
                        if viewModel.isEditable == true {
                            
                            TextFieldRegularView(viewModel: viewModel.textField, font: .systemFont(ofSize: 16))
                                .frame(minWidth: 24)
                            
                        } else {
                            
                            Text(viewModel.value.current ?? "")
                                .foregroundColor(.textSecondary)
                                .font(.textBodyMM14200())
                        }
                        
                        Spacer()
                        
                    }
                }
                
                if viewModel.isEditable, let additionalButton = viewModel.additionalButton {
                    
                    Button(action: additionalButton.action) {
                        
                        additionalButton.icon
                            .foregroundColor(.mainColorsGray)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            
            VStack(spacing: 4) {
             
                if let info = viewModel.info {
                    
                    HStack {
                        
                        Color.clear
                            .frame(width: 24, height: 0)
                            .padding(.leading, 4)
                        
                        Text(info)
                            .font(.textBodySR12160())
                            .foregroundColor(.textPlaceholder)
                        
                        Spacer()
                    }

                }
                
                        
                        
                if let warning = viewModel.warning {
                    
                    HStack {
                        
                        //TODO: chacnge to padding
                        Color.clear
                            .frame(width: 24, height: 0)
                            .padding(.leading, 4)
                        
                        Text(warning)
                            .font(.textBodySR12160())
                            .foregroundColor(.systemColorError)
                        
                        Spacer()
                    }

                }
            }
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 13)
    }
}

//MARK: - Preview

struct PaymentsInputView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsInputView(viewModel: .sampleEmpty)
                .previewLayout(.fixed(width: 375, height: 120))
            
            PaymentsInputView(viewModel: .sampleValue)
                .previewLayout(.fixed(width: 375, height: 100))
            
            PaymentsInputView(viewModel: .sampleValueNotEditable)
                .previewLayout(.fixed(width: 375, height: 100))
            
            PaymentsInputView(viewModel: .samplePhone)
                .previewLayout(.fixed(width: 375, height: 100))
            
            PaymentsInputView(viewModel: .sampleError)
                .previewLayout(.fixed(width: 375, height: 120))
        }
    }
}

//MARK: - Preview Content

extension PaymentsInputView.ViewModel {
    
    static let sampleEmpty = PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: nil), icon: .init(with: UIImage(named: "Payments Input Sample")!)!, title: "ИНН подразделения", validator: .anyValue, limitator: .init(limit: 9)), model: .emptyMock)
    
    static let sampleValue = PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "0016196314"), icon: .init(with: UIImage(named: "Payments Input Sample")!)!, title: "ИНН подразделения", validator: .anyValue, limitator: nil), model: .emptyMock)
    
    static let sampleValueNotEditable = PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "0016196314"), icon: .init(with: UIImage(named: "Payments Input Sample")!)!, title: "ИНН подразделения", validator: .anyValue, limitator: nil, isEditable: false), model: .emptyMock)
    
    static let samplePhone = PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "+9 925 555-5555"), icon: .init(named: "ic24Smartphone")!, title: "Номер телефона получателя", validator: .anyValue, limitator: nil, isEditable: false), model: .emptyMock)
    
    static let sampleWarning = PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "123"), icon: .init(with: UIImage(named: "Payments Input Sample")!)!, title: "ИНН подразделения", validator: .init(rules: [Payments.Validation.MinLengthRule(minLenght: 5, actions: [.post: .warning("Минимальная длинна 5 символов")])]), limitator: nil), model: .emptyMock)
    
    static let sampleError = PaymentsInputView.ViewModel(icon: .init(uiImage: UIImage(named: "Payments Input Sample")!), description: "description", content: "123", info: "info", warning: "warning", textField: .init(text: "123", placeholder: "ИНН подразделения", style: .number, limit: nil), additionalButton: nil, model: .emptyMock)
}

