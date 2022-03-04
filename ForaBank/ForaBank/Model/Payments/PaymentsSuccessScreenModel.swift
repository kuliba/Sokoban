//
//  PaymentsSuccessScreenModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 03.03.2022.
//

import SwiftUI
import Combine

//MARK: - View

struct PaymentsSuccessScreenView: View {
    
    let viewModel: PaymentsSuccessScreenViewModel
    
    var body: some View {
        
        VStack(alignment:.center, spacing: 20) {
            
            viewModel.headerView
                .padding(.top, 134)
            Spacer()
            HStack(alignment: .center, spacing: 20) {
                
                ForEach(viewModel.optionButtons) { buttonViewModel in
                    
                    switch buttonViewModel {
                        
                    case let optionButtonViewModel as PaymentsSuccessOptionButtonView.ViewModel:
                        PaymentsSuccessOptionButtonView(viewModel: optionButtonViewModel)
                        
                    default:
                        EmptyView()
                    }
                }
            }
            
            viewModel.actionButton
                .frame(width: 336, height: 48)
                .padding()
        }
    }
}

//MARK: - Preview

struct PaymentsSuccessScreenView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsSuccessScreenView(viewModel:
                                        .init(headerView: Self.headerView,
                                              optionButtons: Self.optionButtons,
                                              actionButton: Self.actionButton))
    }
}

//MARK: - Preview Content

extension PaymentsSuccessScreenView_Previews {
    
    static let headerView = PaymentsSuccessOptionHeaderView.init(viewModel:
                                                                        .init(stateIcon: Image("OkOperators"),
                                                                              title: "Успешный перевод",
                                                                              description: "1 000,00 ₽",
                                                                              operatorIcon: Image("Payments Service Sample")))
    
    static let optionButtons = [ PaymentsSuccessOptionButtonView.ViewModel(id: UUID(), icon: Image("Operation Details Info"),
                                                                           title: "Детали",
                                                                           action: {}),
                                 
                                 PaymentsSuccessOptionButtonView.ViewModel(id: UUID(), icon: Image("Payments Input Sample"),
                                                                           title: "Документ",
                                                                           action: {}) ]
    
    static let actionButton = ButtonSimpleView(viewModel: .init(state: .active(title: "На главную", action: {})))
}
