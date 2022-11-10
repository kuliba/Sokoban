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
        
        let icon: Image
        let description: String
        @Published var content: String
        @Published var title: String?
        @Published var actionButton: ActionButtonViewModel?
        private var bindings = Set<AnyCancellable>()
        
        private static let iconPlaceholder = Image.ic24File
        
        var parameterInput: Payments.ParameterInput? { source as? Payments.ParameterInput }
        override var isValid: Bool { parameterInput?.validator.isValid(value: content) ?? false }
        
        init(icon: Image, description: String, content: String, actionButton: ActionButtonViewModel? = nil, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.icon = icon
            self.description = description
            self.content = content
            self.actionButton = actionButton
            
            super.init(source: source)
        }
        
        convenience init(with parameterInput: Payments.ParameterInput) {
            
            let icon = parameterInput.icon.image ?? Self.iconPlaceholder
            let description = parameterInput.title
            let content = parameterInput.parameter.value ?? ""

            self.init(icon: icon, description: description, content: content, actionButton: nil, source: parameterInput)
            
            if let actionButtonType = parameterInput.actionButtonType {
                
                self.actionButton = .init(icon: actionButtonType.icon, action: {[weak self] in
                    
                    self?.action.send(PaymentsParameterViewModelAction.Input.ActionButtonDidTapped(type: actionButtonType))
                })
            }
            
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

//MARK: - Types

extension PaymentsInputView.ViewModel {
    
    struct ActionButtonViewModel {
        
        let icon: Image
        let action: () -> Void
    }
}

extension Payments.ParameterInput.ActionButtonType {
    
    var icon: Image {
        
        switch self {
        case .contact: return .ic24User
        }
    }
}

//MARK: - Action

extension PaymentsParameterViewModelAction {
    
    enum Input {
    
        struct ActionButtonDidTapped: Action {
            
            let type: Payments.ParameterInput.ActionButtonType
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
                
                viewModel.icon
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.mainColorsGray)
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

struct PaymentsInputView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsInputView(viewModel: .sampleEmpty)
                .previewLayout(.fixed(width: 375, height: 80))
            
            PaymentsInputView(viewModel: .sampleValue)
                .previewLayout(.fixed(width: 375, height: 80))
            
            PaymentsInputView(viewModel: .sampleValueNotEditable)
                .previewLayout(.fixed(width: 375, height: 80))
            
            PaymentsInputView(viewModel: .samplePhone)
                .previewLayout(.fixed(width: 375, height: 80))
        }
    }
}

//MARK: - Preview Content

extension PaymentsInputView.ViewModel {
    
    static let sampleEmpty = PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: nil), icon: .init(with: UIImage(named: "Payments Input Sample")!)!, title: "ИНН подразделения", validator: .init(minLength: 5, maxLength: nil, regEx: nil)))
    
    static let sampleValue = PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "0016196314"), icon: .init(with: UIImage(named: "Payments Input Sample")!)!, title: "ИНН подразделения", validator: .init(minLength: 5, maxLength: nil, regEx: nil)))
    
    static let sampleValueNotEditable = PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "0016196314"), icon: .init(with: UIImage(named: "Payments Input Sample")!)!, title: "ИНН подразделения", validator: .init(minLength: 5, maxLength: nil, regEx: nil), isEditable: false))
    
    static let samplePhone = PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "+9 925 555-5555"), icon: .init(named: "ic24Smartphone")!, title: "Номер телефона получателя", validator: .init(minLength: 5, maxLength: nil, regEx: nil), isEditable: false, actionButtonType: .contact))
}

