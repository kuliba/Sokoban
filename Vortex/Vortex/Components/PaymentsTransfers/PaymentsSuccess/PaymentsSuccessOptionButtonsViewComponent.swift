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

extension Model {
  
    func makePaymentsSuccessOptionButtonsButtonViewModels(
        withSource source: Payments.ParameterSuccessOptionButtons
    ) -> [any PaymentsSuccessOptionButtonsButtonViewModel] {

        let buttons: [(any PaymentsSuccessOptionButtonsButtonViewModel)?] = source.options.map { option in
            
            switch option {
            case .template:
                
                guard let operationDetail = source.operationDetail,
                      operationDetail.shouldHaveTemplateButton 
                else { return nil }
                
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
                        operation: source.operation,
                        operationDetail: operationDetail
                    )    
                    
                default:
                    
                    if let meToMePayment = source.meToMePayment,
                       let templateID = meToMePayment.templateId,
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
                            operation: nil,
                            operationDetail: operationDetail
                        )
                        
                    }
                    
                    return TemplateButtonView.ViewModel(
                         model: self,
                         state: .idle,
                         operation: nil,
                         operationDetail: operationDetail
                     )
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
//                        .accessibilityIdentifier("SuccessPageTemplateButton")
                    
                case let simpleButton as ButtonViewModel:
                    ButtonView(viewModel: simpleButton) {
                        viewModel.buttonDidTapped(for: button.id)
                    }
                    
                default:
                    EmptyView()
                }
            }
        }
        .frame(height: 120)
    }
}

//MARK: - Internal Views

extension PaymentsSuccessOptionButtonsView {
    
    struct ButtonView: View {
        
        let viewModel: ButtonViewModel
        let action: () -> Void
        
        var body: some View {
            
            Button(action: action) {
                
                ButtonLabel(title: viewModel.title, icon: viewModel.icon)
            }
        }
        
        struct ButtonLabel: View {
            
            let title: String
            let icon: Image
            
            var body: some View {
                
                VStack(spacing: 20) {
                    
                    icon
                        .foregroundColor(.iconBlack)
                        .frame(width: 56, height: 56)
                        .background(Circle().foregroundColor(.mainColorsGrayLightest))
                        .accessibilityIdentifier("SuccessPageButtonIcon")
                    
                    Text(title)
                        .font(.textBodySM12160())
                        .foregroundColor(.textSecondary)
                        .accessibilityIdentifier("SuccessPageButtonTitle")
                }
                .frame(maxWidth: 100)
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
        source: .init(
            options: [.template, .document, .details],
            templateID: nil,
            meToMePayment: nil,
            operation: nil
        )
    )
    
    static let sampleC2B = PaymentsSuccessOptionButtonsView.ViewModel(
        .emptyMock,
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
