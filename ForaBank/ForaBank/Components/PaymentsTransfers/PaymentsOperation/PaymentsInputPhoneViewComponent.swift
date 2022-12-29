//
//  PaymentsInputPhoneViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 01.12.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension PaymentsInputPhoneView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        let icon: Image
        let description: String
        let textField: TextFieldPhoneNumberView.ViewModel
        @Published var title: String?
        @Published var actionButton: ActionButtonViewModel?
        
        private let model: Model
        private static let iconPlaceholder = Image.ic24File
        
        var parameterInput: Payments.ParameterInput? { source as? Payments.ParameterInput }
        override var isValid: Bool {
            
            guard let phone = textField.text else {
                return false
            }
            
#if DEBUG
            if phone.digits == "70115110217" {
                
                return true
                
            } else {
                
                return textField.phoneNumberFormatter.isValid(phone.digits)
            }
            
#else
            return textField.phoneNumberFormatter.isValid(phone.digits)
#endif
        }
        
        init(icon: Image = .ic24Smartphone, description: String, phone: String?, title: String? = nil, actionButton: ActionButtonViewModel? = nil, model: Model = .emptyMock, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.icon = icon
            self.description = description
            self.textField = .init(style: .payments, text: phone, placeHolder: .text(description), filterSymbols: [Character("-"), Character("("), Character(")"), Character("+")], firstDigitReplaceList: [.init(from: "8", to: "7"), .init(from: "9", to: "+7 9")], phoneNumberFormatter: PhoneNumberKitFormater())
            self.title = title
            self.actionButton = actionButton
            self.model = model
            
            super.init(source: source)
        }
        
        convenience init(with parameterInput: Payments.ParameterInputPhone, model: Model) {
            
            let description = parameterInput.title
            let phone = parameterInput.parameter.value

            self.init(description: description, phone: phone, actionButton: nil, model: model, source: parameterInput)
            
            if let phone = phone {

#if DEBUG
                if phone.digits != "70115110217" {
                    
                    textField.text = textField.phoneNumberFormatter.partialFormatter("+\(phone.digits)")
                }

#else
                textField.text = textField.phoneNumberFormatter.partialFormatter("+\(phone.digits)")
#endif
                
            }
            
            self.actionButton = .init(action: {[weak self] in
                
                let contactViewModel = ContactsViewModel(model, mode: .select(.contacts))
                self?.bind(contactsViewModel: contactViewModel)
                self?.action.send(PaymentsParameterViewModelAction.InputPhone.ContactSelector.Show(viewModel: contactViewModel))
            })
            
            textField.toolbar = .init(doneButton: .init(isEnabled: true,
                                                        action: { [weak self] in self?.textField.dismissKeyboard() }),
                                      closeButton: .init(isEnabled: true,
                                                         action: { [weak self] in self?.textField.dismissKeyboard() }))
            
            bind()
        }

        private func bind() {
            
            textField.$text
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] phone in
                    
                    value = value.updated(with: phone)
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        
                        title = phone != nil ? description : nil
                    }

                }.store(in: &bindings)
        }
        
        private func bind(contactsViewModel: ContactsViewModel) {
            
            contactsViewModel.action
                .receive(on: DispatchQueue.main)
                .sink { [weak self] action in
                    
                    switch action {
                    case let payload as ContactsViewModelAction.ContactPhoneSelected:
                        self?.textField.text = payload.phone
                        self?.action.send(PaymentsParameterViewModelAction.InputPhone.ContactSelector.Close())
    
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
        
        VStack(alignment: .leading, spacing: 0) {
            
            if let title = viewModel.title {
                
                Text(title)
                    .font(.textBodySR12160())
                    .foregroundColor(.textPlaceholder)
                    .padding(.bottom, 4)
                    .padding(.leading, 48)
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
                
            }
            
            HStack(spacing: 20) {
                
                viewModel.icon
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.mainColorsGray)
                    .frame(width: 24, height: 24)
                    .padding(.leading, 4)
                
                if viewModel.isEditable == true {
                    
                    TextFieldPhoneNumberView(viewModel: viewModel.textField)
                        .foregroundColor(.textSecondary)
                        .font(.textBodyMM14200())
                        .frame(height: 24)
                    
                } else {
                    
                    Text(viewModel.textField.text ?? "")
                        .foregroundColor(.textSecondary)
                        .font(.textBodyMM14200())
                }
                
                Spacer()
                
                if let actionButton = viewModel.actionButton, viewModel.isEditable == true {
                 
                    Button(action: actionButton.action) {
                        
                        actionButton.icon
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.mainColorsGray)
                            .frame(width: 24, height: 24)
                    }
                }
            }
            
            Divider()
                .frame(height: 1)
                .background(Color.bordersDivider)
                .opacity(viewModel.isEditable ? 1.0 : 0.2)
                .padding(.top, 12)
                .padding(.leading, 48)
        }
    }
}

//MARK: - Preview

struct PaymentsInputPhoneView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsInputPhoneView(viewModel: .samplePhone)
                .previewLayout(.fixed(width: 375, height: 80))
            
            PaymentsInputPhoneView(viewModel: .samplePhoneParam)
                .previewLayout(.fixed(width: 375, height: 80))
        }
    }
}

//MARK: - Preview Content

extension PaymentsInputPhoneView.ViewModel {
    
    static let samplePhone = PaymentsInputPhoneView.ViewModel(description: "Номер телефона получателя", phone: "+7 925 555-5555", title: "Номер телефона получателя", actionButton: .init(action: {}))
    
    static let samplePhoneParam = PaymentsInputPhoneView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "79255145555"), title: "Номер телефона получателя"), model: .emptyMock)
}
