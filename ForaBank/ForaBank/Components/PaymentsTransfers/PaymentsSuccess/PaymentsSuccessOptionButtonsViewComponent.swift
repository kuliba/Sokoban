//
//  PaymentsSuccessOptionButtonsView.swift
//  ForaBank
//
//  Created by Max Gribov on 15.03.2023.
//

import SwiftUI

//MARK: - View Model

extension PaymentsSuccessOptionButtonsView {
    
    typealias Option = Payments.ParameterSuccessOptionButtons.Option
    
    final class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        let buttons: [any PaymentsSuccessOptionButtonsButtonViewModel]
        
        private let model: Model
        
        init(
            _ model: Model,
            buttons: [any PaymentsSuccessOptionButtonsButtonViewModel],
            source: Payments.ParameterSuccessOptionButtons
        ) {
            
            self.model = model
            self.buttons = model.makePaymentsSuccessOptionButtonsButtonViewModels(withSource: source)
            super.init(source: source)
        }
        
        func buttonDidTapped(for option: Option) {

            self.action.send(PaymentsParameterViewModelAction.SuccessOptionButtons.ButtonDidTapped(option: option))
        }
    }
    
    struct ButtonViewModel: PaymentsSuccessOptionButtonsButtonViewModel {
  
        let id: Payments.ParameterSuccessOptionButtons.Option
        let icon: Image
        let title: String
        
        init(id: Payments.ParameterSuccessOptionButtons.Option, icon: Image, title: String) {
            self.id = id
            self.icon = icon
            self.title = title
        }
        
        init(with option: Payments.ParameterSuccessOptionButtons.Option) {
            
            self.init(id: option, icon: option.icon, title: option.title)
        }
    }
}

private extension Model {
  
    func makePaymentsSuccessOptionButtonsButtonViewModels(
        withSource source: Payments.ParameterSuccessOptionButtons
    ) -> [any PaymentsSuccessOptionButtonsButtonViewModel] {

        let buttons: [(any PaymentsSuccessOptionButtonsButtonViewModel)?] = source.options.map { option in
            
            guard let operationDetail = source.operationDetail else {
                return nil
            }
            
            switch option {
            case .template:
                
                switch source.templateID {
                case let .some(templateID):
                    
                    guard let template = self.paymentTemplates.value.first(where: { $0.id == templateID }) else {
                        return nil
                    }
                    
                    let state = TemplateButton.templateButtonState(
                        model: self,
                        template: template,
                        operation: source.operation,
                        meToMePayment: source.meToMePayment,
                        detail: operationDetail
                    )
                    
                    return TemplateButtonView.ViewModel(
                        model: self,
                        state: state,
                        operationDetail: operationDetail
                    )
                    
                    
                default:
                    if let meToMePayment = source.meToMePayment,
                       let templateID = source.templateID,
                       let template = self.paymentTemplates.value.first(where: { $0.id == templateID }) {
                
                        let state = TemplateButton.templateButtonState(
                            model: self,
                            template: template,
                            operation: nil,
                            meToMePayment: meToMePayment,
                            detail: operationDetail
                        )
                        
                       return TemplateButtonView.ViewModel(
                            model: self,
                            state: state,
                            operationDetail: operationDetail
                        )
                        
                    } else {
                     
                        return TemplateButtonView.ViewModel(
                            model: self,
                            operationDetail: operationDetail
                        )
                    }
                }
                
            default:
            
                return PaymentsSuccessOptionButtonsView.ButtonViewModel(with: option)
            }
        }
        
        return buttons.compactMap { $0 }
    }
}

protocol PaymentsSuccessOptionButtonsButtonViewModel: Identifiable {
    
    var id: Payments.ParameterSuccessOptionButtons.Option { get }
}

extension Payments.ParameterSuccessOptionButtons.Option {
    
    var title: String {
        
        switch self {
        case .template: return "Шаблон"
        case .document: return "Документ"
        case .details: return "Детали"
        }
    }
    
    var icon: Image {
        
        switch self {
        case .template: return .ic24Star
        case .document: return .ic24File
        case .details: return .ic24Info
        }
    }
}

//MARK: - Action

extension PaymentsParameterViewModelAction {

    enum SuccessOptionButtons {
    
        struct ButtonDidTapped: Action {
            
            let option: Payments.ParameterSuccessOptionButtons.Option
        }
    }
}

//MARK: - View

struct PaymentsSuccessOptionButtonsView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        HStack(spacing: 8) {
            
            ForEach(viewModel.buttons, id: \.id) { button in
                
                switch button {
                case let viewModel as TemplateButtonView.ViewModel:
                    TemplateButtonView(viewModel: viewModel)
                    
                case let simpleButton as ButtonViewModel:
                    ButtonView(viewModel: simpleButton) {
                        viewModel.buttonDidTapped(for: button.id)
                    }
                    
                default:
                    EmptyView()
                }
            }
        }.padding(.bottom, 16)
    }
}

//MARK: - Internal Views

extension PaymentsSuccessOptionButtonsView {
    
    struct ButtonView: View {
        
        let viewModel: ButtonViewModel
        let action: () -> Void
        
        var body: some View {
            
            Button(action: action) {
                
                VStack(spacing: 20) {
                    
                    viewModel.icon
                        .foregroundColor(.iconBlack)
                        .frame(width: 56, height: 56)
                        .background(Circle().foregroundColor(.mainColorsGrayLightest))
                        
                    Text(viewModel.title)
                        .font(.textBodySM12160())
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: 100)
                }
            }
        }
    }
}

//MARK: - Preview

struct PaymentsSuccessOptionsButtonsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsSuccessOptionButtonsView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 200))
            
            PaymentsSuccessOptionButtonsView.ButtonView(viewModel: .sample, action: {})
                .previewLayout(.fixed(width: 200, height: 200))
        }
    }
}

//MARK: - Preview Content

extension PaymentsSuccessOptionButtonsView.ViewModel {
    
    static let sample = PaymentsSuccessOptionButtonsView.ViewModel(
        .emptyMock,
        buttons: [],
        source: .init(
            options: [.template, .document, .details],
            templateID: nil,
            meToMePayment: nil,
            operation: nil
        )
    )
    
    static let sampleC2B = PaymentsSuccessOptionButtonsView.ViewModel(
        .emptyMock,
        buttons: [],
        source: .init(
            options: [.document, .details],
            templateID: nil,
            meToMePayment: nil,
            operation: nil
        )
    )
}

extension PaymentsSuccessOptionButtonsView.ButtonViewModel {
    
    static let sample = PaymentsSuccessOptionButtonsView.ButtonViewModel(id: .details, icon: .ic24Info, title: "Детали")
}
