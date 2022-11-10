//
//  PaymentsSuccessView.swift
//  ForaBank
//
//  Created by Константин Савялов on 03.03.2022.
//

import SwiftUI

//MARK: - View

struct PaymentsSuccessView: View {
    
    let viewModel: PaymentsSuccessViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack(alignment:.center, spacing: 20) {
            
            HeaderView(viewModel: viewModel.header)
                .padding(.top, 134)
            
            Spacer()
            
            HStack(spacing: 52) {
                
                ForEach(viewModel.optionButtons) { buttonViewModel in
                    
                    switch buttonViewModel {
                    case let optionButtonViewModel as PaymentsSuccessOptionButtonView.ViewModel:
                        PaymentsSuccessOptionButtonView(viewModel: optionButtonViewModel)
                        
                    default:
                        EmptyView()
                    }
                }
            }
            
            ButtonSimpleView(viewModel: viewModel.actionButton)
                .frame(width: 336, height: 48)
                .padding()
        }
    }
}

//MARK: - Subviews

extension PaymentsSuccessView {
    
    struct HeaderView: View {
        
        let viewModel: PaymentsSuccessViewModel.HeaderViewModel
        
        var body: some View {
            
            VStack(alignment:.center, spacing: 0) {
                
                viewModel.stateIcon
                    .frame(width: 88, height: 88)
                    .padding()
                Text(viewModel.title)
                    .font(.textH3SB18240())
                    .foregroundColor(.textSecondary)
                Text(viewModel.description)
                    .font(Font.custom("Inter-SemiBold", size: 24))
                    .foregroundColor(.textSecondary)
                    .padding()
                viewModel.operatorIcon
                    .frame(width: 32, height: 32)
                    .padding()
            }
        }
    }
}

//MARK: - Preview

struct PaymentsSuccessScreenView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsSuccessView(viewModel: .sample)
    }
}

//MARK: - Preview Content

extension PaymentsSuccessViewModel {
    
    static let sample = PaymentsSuccessViewModel(header: .init(stateIcon: Image("OkOperators"), title: "Успешный перевод", description: "1 000,00 ₽", operatorIcon: Image("Payments Service Sample")), optionButtons: [PaymentsSuccessOptionButtonView.ViewModel(id: UUID(), icon: Image("Payments Icon Success Info"), title: "Детали", action: {}), PaymentsSuccessOptionButtonView.ViewModel(id: UUID(), icon: Image("Payments Icon Success File"),title: "Документ", action: {}) ], actionButton: .init(title: "На главную", style: .red, action: {}))
}
