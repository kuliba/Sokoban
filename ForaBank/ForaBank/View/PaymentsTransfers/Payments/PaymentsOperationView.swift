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
            
            // top
            if let topItems = viewModel.top {
                
                VStack {
                    
                    ForEach(topItems) { item in
                        
                        //TODO: render top items
                        Color.clear
                    }
                    
                    Spacer()
                }
            }
            
            // content
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 20) {
                    
                    ForEach(viewModel.content) { item in
                        
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
                            
                        case let cardViewModel as PaymentsProductView.ViewModel:
                            PaymentsProductView(viewModel: cardViewModel)
                            
                        case let selectViewModels as PaymentsSelectSimpleView.ViewModel:
                            PaymentsSelectSimpleView(viewModel: selectViewModels)
                            
                        case let additionButtonViewModel as PaymentsSpoilerButtonView.ViewModel:
                            PaymentsSpoilerButtonView(viewModel: additionButtonViewModel)
                            
                        default:
                            Color.clear
                            
                        }
                    }
                }
                
            }.padding(.horizontal, 20)
            
            // bottom
            if let bottomItems = viewModel.bottom {
                
                VStack {
                    
                    Spacer()
                    
                        ForEach(bottomItems) { item in
                            
                            switch item {
                            case let continueViewModel as PaymentsContinueButtonView.ViewModel:
                                PaymentsContinueButtonView(viewModel: continueViewModel)
                                
                            case let amountViewModel as PaymentsAmountView.ViewModel:
                                PaymentsAmountView(viewModel: amountViewModel)
                                
                            default:
                                Color.clear
                            }
                            
                        }.modifier(BottomBackgroundModifier())
                }
            }
        }
        .navigationBarTitle(Text(viewModel.header.title), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: { self.presentationMode.wrappedValue.dismiss() }, label: {
            viewModel.header.backButtonIcon }))
    }
}

extension PaymentsOperationView {
    
    struct BottomBackgroundModifier: ViewModifier {
        
        func body(content: Content) -> some View {
            
            if #available(iOS 15.0, *) {
                
                content
                    .background(.ultraThinMaterial, ignoresSafeAreaEdges: .bottom)
                
            } else {
                
                content
                    .background(Color.white.opacity(0.95).ignoresSafeArea(.container, edges: .bottom))
            }
        }
    }
}

struct PaymentsOperationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            NavigationView {
                PaymentsOperationView(viewModel: .sampleContinue)
            }
            
            NavigationView {
                PaymentsOperationView(viewModel: .sampleAmount)
            }
        }
    }
}

extension PaymentsOperationViewModel {
    
    static let sampleContinue: PaymentsOperationViewModel = {
        
        let contentItems = [PaymentsSwitchView.ViewModel.sample, PaymentsSelectView.ViewModel.selectedMock, PaymentsInfoView.ViewModel.sample, PaymentsNameView.ViewModel.normal, PaymentsNameView.ViewModel.edit, PaymentsProductView.ViewModel.sample, PaymentsInfoView.ViewModel.sample]
        let bottomItems = [PaymentsContinueButtonView.ViewModel.sample]
        
        return PaymentsOperationViewModel(header: .init(title: "Налоги и услуги"), top: nil, content: contentItems, bottom: bottomItems, link: nil, bottomSheet: nil, operation: .emptyMock, model: .emptyMock)
    }()
    
    static let sampleAmount: PaymentsOperationViewModel = {
        
        let contentItems = [PaymentsSwitchView.ViewModel.sample, PaymentsSelectView.ViewModel.selectedMock, PaymentsInfoView.ViewModel.sample, PaymentsNameView.ViewModel.normal, PaymentsNameView.ViewModel.edit, PaymentsProductView.ViewModel.sample]
        let bottomItems = [PaymentsAmountView.ViewModel.amount]
        
        return PaymentsOperationViewModel(header: .init(title: "Налоги и услуги"), top: nil, content: contentItems, bottom: bottomItems, link: nil, bottomSheet: nil, operation: .emptyMock, model: .emptyMock)
    }()
}

