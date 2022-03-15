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
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        
        ZStack {
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 20) {
                    
                    ForEach(viewModel.itemsVisible) { item in
                        
                        switch item {
                        case let selectViewModel as PaymentsSelectView.ViewModel:
                            PaymentsSelectView(viewModel: selectViewModel)
                            
                        case let switchViewModel as PaymentsSwitchView.ViewModel:
                            PaymentsSwitchView(viewModel: switchViewModel)
                            
                        case let inputViewModel as PaymentsInputView.ViewModel:
                            PaymentsInputView(viewModel: inputViewModel)
                            
                        case let infoViewModel as PaymentsInfoView.ViewModel:
                            PaymentsInfoView(viewModel: infoViewModel)
                            
                        case let nameViewModel as PaymentsNameView.ViewModel:
                            PaymentsNameView(viewModel: nameViewModel)
                            
                        case let cardViewModel as PaymentsCardView.ViewModel:
                            PaymentsCardView(viewModel: cardViewModel)
                            
                        case let selectViewModels as PaymentsSelectSimpleView.ViewModel:
                            PaymentsSelectSimpleView(viewModel: selectViewModels)
                            
                        case let additionButtonViewModel as PaymentsButtonAdditionalView.ViewModel:
                            PaymentsButtonAdditionalView(viewModel: additionButtonViewModel)
                            
                        default:
                            Color.clear
                            
                        }
                    }
                    
                    Color.clear
                        .frame(height: 120)
                }
            }
            .padding(.horizontal, 20)
            
            if let footerViewModel = viewModel.footer {
                
                VStack {
                    
                    Spacer()
                    
                    switch footerViewModel {
                    case .button(let continueButtonViewModel):

                        
                        ZStack {
                            
                            Color.white
                                .opacity(0.9)
                                .edgesIgnoringSafeArea(.bottom)

                            ButtonSimpleView(viewModel: .init(buttonModel: continueButtonViewModel))
                                .frame(height: 42)
                            .padding(.horizontal, 20)
                            
                        }.frame(height: 60)
                        
                    case .amount(let amountViewModel):
                        PaymentsAmountView(viewModel: amountViewModel)
                            .edgesIgnoringSafeArea(.bottom)
                    }
                }
            }
                    
            NavigationLink("", isActive: $viewModel.isConfirmViewActive) {
                
                if let confirmViewModel = viewModel.confirmViewModel {

                        PaymentsOperationView(viewModel: confirmViewModel)
                    
                } else {
                    
                    EmptyView()
                }
            }
        }
        .navigationBarTitle(Text(viewModel.header.title), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: { self.presentationMode.wrappedValue.dismiss()}, label: {
            viewModel.header.backButtonIcon }))
        .fullScreenCoverLegacy(viewModel: $viewModel.popUpSelector, coverBackgroundColor: .clear) { popUpSelectViewModel in
            PaymentsPopUpSelectView(viewModel: popUpSelectViewModel)
        }
    }
}

struct PaymentsOperationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsOperationView(viewModel: .sample)
    }
}

extension PaymentsOperationViewModel {
    
    static let sample: PaymentsOperationViewModel = {
        
        let items: [PaymentsParameterViewModel] = [PaymentsSwitchView.ViewModel.sample, PaymentsSelectView.ViewModel.selectedMock, PaymentsInfoView.ViewModel.sample, PaymentsNameView.ViewModel.normal, PaymentsNameView.ViewModel.edit, PaymentsCardView.ViewModel.sample]
        
        return PaymentsOperationViewModel(header: .init(title: "Налоги и услуги", action: {}), items: items, footer: .amount(PaymentsAmountView.ViewModel.amountCurrencyInfoAlert))
    }()
}
