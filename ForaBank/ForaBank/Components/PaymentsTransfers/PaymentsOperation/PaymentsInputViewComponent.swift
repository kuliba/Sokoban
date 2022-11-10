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
    
    class ViewModel: PaymentsParameterViewModel {
        
        let logo: Image
        let description: String
        @Published var content: String
        @Published var title: String?
        @Published var actionButton: ActionButtonViewModel?
        let validator: Payments.ParameterInput.Validator
        private var bindings = Set<AnyCancellable>()
        
        private static let iconPlaceholder = Image("Payments Icon Placeholder")
        
        override var isValid: Bool {
            
            guard let inputParemeter = source as? Payments.ParameterInput else {
                return false
            }
            
            return inputParemeter.validator.isValid(value: content)
        }
        
        struct ActionButtonViewModel {
            
            let type: Payments.ParameterInput.ActionButtonType
            var icon: Image {
                switch type {
                case .contact: return .ic24User
                }
            }
            let action: () -> Void
        }

        
        init(logo: Image, description: String, content: String, validator: Payments.ParameterInput.Validator = .init(minLength: 0, maxLength: 50, regEx: nil), source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString), actionButton: ActionButtonViewModel? = nil) {
            
            self.logo = logo
            self.description = description
            self.content = content
            self.validator = validator
            self.actionButton = actionButton
            
            super.init(source: source)
        }
        
        init(with parameterInput: Payments.ParameterInput) {
            
            self.logo = parameterInput.icon.image ?? Self.iconPlaceholder
            self.content = parameterInput.parameter.value ?? ""
            self.description = parameterInput.title
            self.validator = parameterInput.validator
            
            if let actionButton = parameterInput.actionButton {
                
                self.actionButton = .init(type: actionButton, action: {})
            }
            
            super.init(source: parameterInput)
            
            bind()
        }

        private func bind() {
            
            $content
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] content in
                    
                    value = value.updated(with: content)
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        
                        title = content.count > 0 ? description : nil
                    }

                }.store(in: &bindings)
        }
    }
}

//MARK: - View

struct PaymentsInputView: View {
    
    @ObservedObject var viewModel: PaymentsInputView.ViewModel
    
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
                
                viewModel.logo
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.leading, 4)
                
                if viewModel.isEditable == true {
                    
                    TextField(viewModel.description, text: $viewModel.content)
                        .foregroundColor(.textSecondary)
                        .font(.textBodyMM14200())
                        .textFieldStyle(DefaultTextFieldStyle())
                    
                } else {
                    
                    Text(viewModel.content)
                        .foregroundColor(.textSecondary)
                        .font(.textBodyMM14200())
                }
                
                Spacer()
                
                if let actionButton = viewModel.actionButton {
                 
                    Button(action: actionButton.action) {
                        
                        actionButton.icon
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

struct PaymentsInputView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsInputView(viewModel: .sampleEmpty)
                .previewLayout(.fixed(width: 375, height: 80))
            
            PaymentsInputView(viewModel: .sampleValue)
                .previewLayout(.fixed(width: 375, height: 80))
            
            PaymentsInputView(viewModel: .sampleValueNotEditable)
                .previewLayout(.fixed(width: 375, height: 80))
        }
    }
}

//MARK: - Preview Content

extension PaymentsInputView.ViewModel {
    
    static let sampleEmpty = try! PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: nil), icon: .init(with: UIImage(named: "Payments Input Sample")!)!, title: "ИНН подразделения", validator: .init(minLength: 5, maxLength: nil, regEx: nil)))
    
    static let sampleValue = try! PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "0016196314"), icon: .init(with: UIImage(named: "Payments Input Sample")!)!, title: "ИНН подразделения", validator: .init(minLength: 5, maxLength: nil, regEx: nil)))
    
    static let sampleValueNotEditable = try! PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "0016196314"), icon: .init(with: UIImage(named: "Payments Input Sample")!)!, title: "ИНН подразделения", validator: .init(minLength: 5, maxLength: nil, regEx: nil), isEditable: false))
}

