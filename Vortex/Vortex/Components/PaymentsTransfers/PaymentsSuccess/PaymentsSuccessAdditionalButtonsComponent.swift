//
//  PaymentsSuccessAdditionalButtonsComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 22.06.2023.
//

import SwiftUI

extension PaymentsSuccessAdditionalButtonsView {
    
    final class ViewModel: PaymentsParameterViewModel {
        
        let buttons: [ButtonViewModel]
        
        init(buttons: [ButtonViewModel], source: PaymentsParameterRepresentable) {
            
            self.buttons = buttons
            super.init(source: source)
        }
        
        convenience init(_ source: Payments.ParameterSuccessAdditionalButtons) {
            
            self.init(buttons: source.options.map(ButtonViewModel.init), source: source)
        }
        
        func buttonDidTapped(id: Payments.ParameterSuccessAdditionalButtons.Option) {
            
            action.send(PaymentsParameterViewModelAction.SuccessAdditionalButtons.ButtonDidTapped(option: id))
        }
        
        struct ButtonViewModel: Identifiable {
            
            let id: Payments.ParameterSuccessAdditionalButtons.Option
            var title: String { id.title }
        }
    }
}

struct PaymentsSuccessAdditionalButtonsView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        HStack(spacing: 16) {
            
            ForEach(viewModel.buttons) { button in
                
                ButtonSimpleView(
                    viewModel: .init(
                        title: button.title,
                        style: .gray,
                        action: { viewModel.buttonDidTapped(id: button.id) }
                    )
                )
                .frame(height: 48)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Action

extension PaymentsParameterViewModelAction {
    
    enum SuccessAdditionalButtons {
        
        struct ButtonDidTapped: Action {
            
            let option: Payments.ParameterSuccessAdditionalButtons.Option
        }
    }
}
