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
        
        init(_ model: Model, buttons: [any PaymentsSuccessOptionButtonsButtonViewModel], source: PaymentsParameterRepresentable) {
            
            self.model = model
            self.buttons = buttons
            super.init(source: source)
        }
        
        convenience init(_ model: Model, _ source: Payments.ParameterSuccessOptionButtons) {
            
            let buttons: [ButtonViewModel?] = source.options.map { option in
                
                switch option {
                case .template:
                    guard source.operationDetail != nil else { return nil }
                    return ButtonViewModel(with: option)
                    
                default:
                    return ButtonViewModel(with: option)
                }
            }
        
            self.init(model, buttons: buttons.compactMap { $0 }, source: source)
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
    
    static let sample = PaymentsSuccessOptionButtonsView.ViewModel(.emptyMock, .init(options: [.template, .document, .details]))
    
    static let sampleC2B = PaymentsSuccessOptionButtonsView.ViewModel(.emptyMock, .init(options: [.document, .details]))
}

extension PaymentsSuccessOptionButtonsView.ButtonViewModel {
    
    static let sample = PaymentsSuccessOptionButtonsView.ButtonViewModel(id: .details, icon: .ic24Info, title: "Детали")
}
