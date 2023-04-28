//
//  PaymentsSubscribeViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 02.02.2023.
//

import SwiftUI

//MARK: - View Model

extension PaymentsSubscribeView {
    
    class ViewModel: PaymentsParameterViewModel, PaymentsParameterViewModelContinuable, ObservableObject {

        @Published var buttons: [ButtonSimpleView.ViewModel]
        let icon: Image
        
        override var isValid: Bool { value.current != nil }
        
        private var parameterSubscribe: Payments.ParameterSubscribe? { source as? Payments.ParameterSubscribe }
        
        init(buttons: [ButtonSimpleView.ViewModel], icon: Image, source: PaymentsParameterRepresentable) {
            
            self.buttons = buttons
            self.icon = icon
            super.init(source: source)
        }
        
        convenience init(with parameterSubscribe: Payments.ParameterSubscribe) {
            
            self.init(buttons: [], icon: Image(parameterSubscribe.icon), source: parameterSubscribe)
            
            self.buttons = reduce(parameterSubscribe: parameterSubscribe, parameterValue: parameterValue)
            
            bind()
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as PaymentsParameterViewModelAction.Subscribe.ButtonDidTapped:
                        update(value: payload.action.rawValue)
                        
                        self.action.send(PaymentsParameterViewModelAction.ContinueButton.DidTapped())
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
        }
        
        override func update(source: PaymentsParameterRepresentable) {
            super.update(source: source)
            
            guard let parameterSubscribe = parameterSubscribe else {
                return
            }
            
            self.buttons = reduce(parameterSubscribe: parameterSubscribe, parameterValue: parameterValue)
        }
        
        func update(isContinueEnabled: Bool) {
            
        }
        
        func reduce(parameterSubscribe: Payments.ParameterSubscribe, parameterValue: ((Payments.Parameter.ID) -> Payments.Parameter.Value)?) -> [ButtonSimpleView.ViewModel] {
            
            parameterSubscribe.buttons.map { button in
                
                var isPreconditionPassed = true
                if let precondition = button.precondition {
                    
                    if let parameterValueCallback = parameterValue,
                       let value = parameterValueCallback(precondition.parameterId),
                       precondition.value == value {
                        
                        isPreconditionPassed = true
                        
                    } else {
                        
                        isPreconditionPassed = false
                    }
                }
                
                let buttonStyle = ButtonSimpleView.ViewModel.ButtonStyle(style: button.style, isPreconditionPassed: isPreconditionPassed)

                let buttonViewModel = ButtonSimpleView.ViewModel(title: button.title, style: buttonStyle) {[weak self] in
                    
                    self?.action.send(PaymentsParameterViewModelAction.Subscribe.ButtonDidTapped(action: button.action))
                }
                
                return buttonViewModel
            }
        }
    }
    
}

//MARK: - Types

extension ButtonSimpleView.ViewModel.ButtonStyle {
    
    init(style: Payments.ParameterSubscribe.Button.Style, isPreconditionPassed: Bool) {
        
        if isPreconditionPassed == true {
            
            switch style {
            case .primary:
                self = .red
                
            case .secondary:
                self = .gray
            }
            
        } else {
            
            self = .inactive
        }
    }
}

//MARK: - Actions

extension PaymentsParameterViewModelAction {
    
    enum Subscribe {
        
        struct ButtonDidTapped: Action {
            
            let action: Payments.ParameterSubscribe.Button.Action
        }
    }
}

struct PaymentsSubscribeView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack {
            
            ForEach(viewModel.buttons) { buttonViewModel in
                
                ButtonSimpleView(viewModel: buttonViewModel)
                    .frame(height: 56)
            }
            
            viewModel.icon
                .renderingMode(.original)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
    }
}

struct PaymentsSubscribeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsSubscribeView(viewModel: .init(buttons: [.init(title: "Привязать счет", style: .red, action: {}), .init(title: "Пока нет", style: .gray, action: {})], icon: .ic72Sbp, source: Payments.ParameterMock()))
            .previewLayout(.fixed(width: 375, height: 300))
    }
}
