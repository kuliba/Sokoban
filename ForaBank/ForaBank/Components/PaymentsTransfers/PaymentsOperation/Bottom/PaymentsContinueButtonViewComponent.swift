//
//  PaymentsContinueButtonViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 27.10.2022.
//

import SwiftUI

extension PaymentsContinueButtonView {
    
    class ViewModel: PaymentsParameterViewModel, PaymentsParameterViewModelContinuable, ObservableObject {
        
        let title: String
        @Published var button: ButtonSimpleView.ViewModel
        
        init(title: String, button: ButtonSimpleView.ViewModel = .init(title: "", style: .inactive, action: {}), source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.title = title
            self.button = button
            super.init(source: source)
        }
        
        func update(isContinueEnabled: Bool) {
            
            if isContinueEnabled == true {
                
                button = .init(title: title, style: .red) {[weak self] in
                    
                    self?.action.send(PaymentsParameterViewModelAction.ContinueButton.DidTapped())
                }
                
            } else {
                
                button = .init(title: title, style: .inactive, action: {})
            }
        }
    }
}

//MARK: - Action

extension PaymentsParameterViewModelAction {

    enum ContinueButton {
    
        struct DidTapped: Action {}
    }
}

//MARK: - View

struct PaymentsContinueButtonView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        ButtonSimpleView(viewModel: viewModel.button)
            .frame(height: 56)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
    }
}

//MARK: - Preview

struct PaymentsContinueViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsContinueButtonView(viewModel: .sample)
    }
}

//MARK: - Preview Content

extension PaymentsContinueButtonView.ViewModel {
    
    static let sample = PaymentsContinueButtonView.ViewModel(title: "Продолжить", button: .init(title: "Продолжить", style: .red, action: {}))
}

