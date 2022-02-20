//
//  PaymentsOperationViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 16.02.2022.
//

import SwiftUI
import Combine

struct PaymentsOperationView: View {
    
    @ObservedObject var viewModel: PaymentsOperationViewModel
    
    var body: some View {
        
        ZStack {
            
            ScrollView {
                
                VStack(spacing: 20) {
                    
                    ForEach(viewModel.items, id: \.self.id) { item in
                        
                        switch item {
                        case let selectViewModel as PaymentsParameterSelectView.ViewModel:
                            PaymentsParameterSelectView(viewModel: selectViewModel)
                            
                        case let switchViewModel as PaymentsParameterSwitchView.ViewModel:
                            PaymentsParameterSwitchView(viewModel: switchViewModel)
                            
                        case let inputViewModel as PaymentsParameterInputView.ViewModel:
                            PaymentsParameterInputView(viewModel: inputViewModel)
                            
                        case let infoViewModel as PaymentsParameterInfoView.ViewModel:
                            PaymentsParameterInfoView(viewModel: infoViewModel)
                            
                        case let nameViewModel as PaymentsParameterNameView.ViewModel:
                            PaymentsParameterNameView(viewModel: nameViewModel)
                            
                        case let cardViewModel as PaymentsParameterCardView.ViewModel:
                            PaymentsParameterCardView(viewModel: cardViewModel)
                            
                        default:
                            Color.clear
                            
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            
            if let amountViewModel = viewModel.amount {
                
                VStack {
                    
                    Spacer()
                    
                    PaymentsParameterAmountView(viewModel: amountViewModel)
                        .edgesIgnoringSafeArea(.bottom)
                }
            }
        }
        .navigationBarTitle(Text(viewModel.header.title), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: viewModel.header.action, label: {
            viewModel.header.backButtonIcon
        }))
        
    }
}

struct PaymentsOperationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsOperationView(viewModel: .sample)
    }
}

extension PaymentsOperationViewModel {
    
    
    static let sample: PaymentsOperationViewModel = {
        
        let items: [PaymentsParameterViewModel] = [PaymentsParameterSwitchView.ViewModel.sample, PaymentsParameterSelectView.ViewModel.selectedMock, PaymentsParameterInfoView.ViewModel.sample, PaymentsParameterNameView.ViewModel.normal, PaymentsParameterNameView.ViewModel.edit, PaymentsParameterCardView.ViewModel.sample]
        
        return PaymentsOperationViewModel(header: .init(title: "Налоги и услуги", action: {}), items: items, amount: PaymentsParameterAmountView.ViewModel.amountCurrencyInfoAlert)
    }()
}
