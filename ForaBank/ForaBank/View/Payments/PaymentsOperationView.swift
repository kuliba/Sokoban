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
            
            ScrollView(showsIndicators: false) {
                
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
                            
                        case let selectViewModels as PaymentsParameterSelectSimpleView.ViewModel:
                            PaymentsParameterSelectSimpleView(viewModel: selectViewModels)
                            
                        default:
                            Color.clear
                            
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            
            if let footerViewModel = viewModel.footer {
                
                VStack {
                    
                    Spacer()
                    
                    switch footerViewModel {
                    case .button(let continueButtonViewModel):

                        ButtonSimpleView(viewModel: .init(buttonModel: continueButtonViewModel))
                            .frame(height: 42)
                            .padding(.horizontal, 20)
                        
//                        if continueButtonViewModel.isEnabled {
//                            ButtonSimpleView(
//                                viewModel: ButtonSimpleView.ViewModel(
//                                    state: .active(
//                                        title: continueButtonViewModel.title,
//                                        action: continueButtonViewModel.action)))
//                                .frame(height: 42)
//                                .padding(.horizontal, 20)
//                        } else {
//                            ButtonSimpleView(
//                                viewModel: ButtonSimpleView.ViewModel(
//                                    state: .inactive(title: continueButtonViewModel.title)))
//                                .frame(height: 42)
//                                .padding(.horizontal, 20)
//                        }
                        
                    case .amount(let amountViewModel):
                        PaymentsParameterAmountView(viewModel: amountViewModel)
                            .edgesIgnoringSafeArea(.bottom)
                    }
                }
            }
            
            if let popUpSelectViewModel = viewModel.popUpSelector {
                
                PaymentsPopUpSelectView(viewModel: popUpSelectViewModel)
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
        
        return PaymentsOperationViewModel(header: .init(title: "Налоги и услуги", action: {}), items: items, footer: .amount(PaymentsParameterAmountView.ViewModel.amountCurrencyInfoAlert))
    }()
}
