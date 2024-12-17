//
//  PaymentsContinueButtonViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 27.10.2022.
//

import SwiftUI

extension PaymentsButtonView {
    
    class ViewModel: PaymentsParameterViewModel, PaymentsParameterViewModelContinuable, ObservableObject {

        @Published var button: ButtonSimpleView.ViewModel
        var buttonParameter: Payments.ParameterButton? { source as? Payments.ParameterButton }
        
        init(button: ButtonSimpleView.ViewModel, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.button = button
            super.init(source: source)
        }
        
        convenience init(_ source: Payments.ParameterButton) {
            
            self.init(button: .init(title: "", style: .red, action: {}), source: source)
            
            self.button = .init(title: source.title, style: .init(with: source.style), action: { [weak self] in
                
                self?.action.send(PaymentsParameterViewModelAction.Button.DidTapped(action: source.action))
            })
        }
        
        func update(isContinueEnabled: Bool) {
            
            guard let buttonParameter = buttonParameter  else {
                return
            }
            
            guard buttonParameter.action == .continue else {
                return
            }
            
            update(isEnabled: isContinueEnabled)
        }
        
        func update(isEnabled: Bool) {
            
            guard let buttonParameter = buttonParameter  else {
                return
            }
            
            if isEnabled == true {
                
                button = .init(title: buttonParameter.title, style: .init(with: buttonParameter.style)) {[weak self] in
                    
                    self?.action.send(PaymentsParameterViewModelAction.Button.DidTapped(action: buttonParameter.action))
                }
                
            } else {
                
                button = .init(title: buttonParameter.title, style: .inactive, action: {})
            }
        }
    }
}

extension ButtonSimpleView.ViewModel.ButtonStyle {
    
    init(with style: Payments.ParameterButton.Style) {
        
        switch style {
        case .primary: self = .red
        case .secondary: self = .gray
        case .gray: self = .gray
        }
    }
}

//MARK: - Action

extension PaymentsParameterViewModelAction {

    enum Button {
    
        struct DidTapped: Action {
            
            let action: Payments.ParameterButton.Action
        }
    }
}

//MARK: - View

struct PaymentsButtonView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        ButtonSimpleView(viewModel: viewModel.button)
            .frame(height: 56)
            .accessibilityIdentifier("PaymentsButtonContinueButton")
    }
}

//MARK: - Preview

struct PaymentsButtonViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            VStack(spacing: 32, content: previewsGroup)
                .previewDisplayName("Xcode 14+")
            
            previewsGroup()
        }
    }
    
    static func previewsGroup() -> some View {
        
        Group {
            
            PaymentsButtonView(viewModel: .sample)
            PaymentsButtonView(viewModel: .sampleInactive)
            PaymentsButtonView(viewModel: .sampleParam)
            PaymentsButtonView(viewModel: .sampleParamSecondary)
        }
        .previewLayout(.fixed(width: 375, height: 100))
    }
}

//MARK: - Preview Content

extension PaymentsButtonView.ViewModel {
    
    static let sample = PaymentsButtonView.ViewModel(button: .init(title: "Продолжить", style: .red, action: {}))
    
    static let sampleInactive = PaymentsButtonView.ViewModel(button: .init(title: "Продолжить", style: .inactive, action: {}))
    
    static let sampleParam: PaymentsButtonView.ViewModel = {
        
        let vm = PaymentsButtonView.ViewModel(.init(parameterId: UUID().uuidString, title: "Продолжить", style: .primary, acton: .main))
        vm.update(isContinueEnabled: true)
        
        return vm
    }()
    
    static let sampleParamSecondary = PaymentsButtonView.ViewModel(.init(parameterId: UUID().uuidString, title: "Отмена", style: .secondary, acton: .main))
}

