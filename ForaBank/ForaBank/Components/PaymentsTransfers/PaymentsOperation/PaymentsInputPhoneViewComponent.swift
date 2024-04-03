//
//  PaymentsInputPhoneViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 01.12.2022.
//

import SwiftUI
import Combine
import TextFieldComponent

//MARK: - ViewModel

extension PaymentsInputPhoneView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        let icon: Image
        let textView: RegularFieldViewModel
        @Published var title: String?
        @Published var actionButton: ActionButtonViewModel?
        
        private let model: Model
        private static let iconPlaceholder = Image.ic24File
        
        var parameterInput: Payments.ParameterInputPhone? { source as? Payments.ParameterInputPhone }
        override var isValid: Bool {
            
            guard let phone = textView.text else {
                return false
            }
            
            let validator = PhoneValidator()
            
#if DEBUG || PREPROD
            return getDebugValidation(phone: phone.digits)
#else
            return validator.isValid(phone.digits)
#endif
        }
        
        var titleValue: String? { parameterInput?.title }

        init(icon: Image = .ic24Smartphone, textView: RegularFieldViewModel, phone: String?, title: String? = nil, actionButton: ActionButtonViewModel? = nil, model: Model = .emptyMock, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.icon = icon
            self.textView = textView
            self.title = title
            self.actionButton = actionButton
            self.model = model
            
            super.init(source: source)
        }
        
        convenience init(with parameterInput: Payments.ParameterInputPhone, model: Model) {
            
            let title = parameterInput.title
            let phone = parameterInput.parameter.value
            let placeholder = parameterInput.placeholder ?? parameterInput.title
            let countryCodes: [CountryCodeReplace] = parameterInput.countryCode ?? []

            let textView = TextFieldFactory.makePhoneKitTextField(
                initialPhoneNumber: phone,
                placeholderText: placeholder,
                filterSymbols: [],
                countryCodeReplaces: countryCodes
            )
            
            self.init(textView: textView, phone: phone, title: title, model: model, source: parameterInput)
            
            if let phone = phone {
#if DEBUG
                if phone.digits != "70115110217" {
                    
                    textView.setText(to: "+\(phone.digits)")
                }
#else
                textView.setText(to: "+\(phone.digits)")
#endif
            }
            
            self.actionButton = .init(action: {[weak self] in
                
                let contactViewModel = model.makeContactsViewModel(forMode: .select(.contacts))
                self?.bind(contactsViewModel: contactViewModel)
                self?.action.send(PaymentsParameterViewModelAction.InputPhone.ContactSelector.Show(viewModel: contactViewModel))
            })
            
            bind()
        }

        private func bind() {
            
            textView.textPublisher()
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] phone in
                    
                    update(value: phone)

                }.store(in: &bindings)
            
            textView.isEditing()
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isEditing in
                                        
                    if isEditing || textView.hasValue {

                        withAnimation {

                            title = titleValue
                        }
                        
                        if isEditing,
                           value.last != value.current,
                           value.id == Payments.Parameter.Identifier.sfpPhone.rawValue,
                           let phone = value.current,
                           PhoneValidator().isValid(phone) {
                            
                            model.action.send(ModelAction.LatestPayments.BanksList.Request(prePayment: false, phone: phone))
                        }

                    } else {

                        withAnimation {

                            title = nil
                        }
                    }

                }.store(in: &bindings)
        }
        
        private func bind(contactsViewModel: ContactsViewModel) {
            
            contactsViewModel.action
                .receive(on: DispatchQueue.main)
                .sink { [weak self] action in
                    
                    switch action {
                    case let payload as ContactsViewModelAction.ContactPhoneSelected:
                        self?.textView.setText(to: payload.phone)
                        self?.action.send(PaymentsParameterViewModelAction.InputPhone.ContactSelector.Close())
                        self?.model.action.send(ModelAction.LatestPayments.BanksList.Request(phone: payload.phone))
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
    }
}

//MARK: - Types

extension PaymentsInputPhoneView.ViewModel {
    
    struct ActionButtonViewModel {
        
        let icon: Image = .ic24User
        let action: () -> Void
    }
}

//MARK: - Action

extension PaymentsParameterViewModelAction {
    
    enum InputPhone {
    
        enum ContactSelector {
            
            struct Show: Action {
                
                let viewModel: ContactsViewModel
            }
            
            struct Close: Action {}
        }
    }
}

//MARK: - View

struct PaymentsInputPhoneView: View {
    
    @ObservedObject var viewModel: PaymentsInputPhoneView.ViewModel
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            leadingIcon
                .frame(width: 24, height: 24)
            
            centerView
                .padding(.leading, 4)
            
            trailingButton
        }
        .frame(height: 72)
        .padding(.horizontal, 16)
        .background(Color.mainColorsGrayLightest)
        .cornerRadius(12)
    }
    
    private var leadingIcon: some View {
        
        viewModel.icon
            .resizable()
            .renderingMode(.template)
            .foregroundColor(.mainColorsGray)
    }
    
    private var centerView: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            if let title = viewModel.title {
                
                Text(title)
                    .font(.textBodyMM14200())
                    .foregroundColor(.textPlaceholder)
                    .padding(.bottom, 4)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom),
                            removal: .opacity
                        )
                    )
                    .accessibilityIdentifier("PaymentsInputPhoneTitle")
            }
            
            HStack(spacing: 20) {
                
                if viewModel.isEditable {
                    
                    RegularTextFieldView(
                        viewModel: viewModel.textView,
                        textFieldConfig: .black16
                    )
                    .frame(height: 24)
                    
                } else {
                    
                    Text(viewModel.textView.text ?? "")
                }
            }
            .foregroundColor(.textSecondary)
            .font(.textH4M16240())
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("PaymentsInputPhoneField")
        }
    }

    @ViewBuilder
    private var trailingButton: some View {

        if let actionButton = viewModel.actionButton,
            viewModel.isEditable {
            
            Button(action: actionButton.action) {
                
                actionButton.icon
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.mainColorsGray)
                    .frame(width: 24, height: 24)
                    .accessibilityIdentifier("PaymentsInputPhoneContactsIcon")
            }
        }
    }
}

//MARK: - Preview

struct PaymentsInputPhoneView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            previewGroup()
                .previewLayout(.fixed(width: 375, height: 80))
            
            VStack(spacing: 32, content: previewGroup)
                .previewLayout(.sizeThatFits)
        }
    }
    
    static func previewGroup() -> some View {
        
        Group {
            
            PaymentsInputPhoneView(viewModel: .samplePhone)
            
            PaymentsInputPhoneView(viewModel: .samplePhoneParam)
        }
    }
}

//MARK: - Preview Content

extension PaymentsInputPhoneView.ViewModel {
    
    static let samplePhone = PaymentsInputPhoneView.ViewModel(
        textView: TextFieldFactory.makePhoneKitTextField(
            initialPhoneNumber: "+7 925 555-5555",
            placeholderText: "Номер телефона получателя",
            filterSymbols: [],
            countryCodeReplaces: []
        ),
        phone: "+7 925 555-5555",
        title: "Номер телефона получателя",
        actionButton: .init(action: {})
    )
    
    static let samplePhoneParam = PaymentsInputPhoneView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "79255145555"), title: "Номер телефона получателя"), model: .emptyMock)
}

private extension PaymentsInputPhoneView.ViewModel {
    
    private func getDebugValidation(
        phone: String,
        validator: PhoneValidator = PhoneValidator()
    ) -> Bool {
        
        return phone.digits == "70115110217" ? true : validator.isValid(phone.digits)
    }
}
