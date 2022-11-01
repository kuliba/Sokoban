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
                            
                        case let additionButtonViewModel as PaymentsButtonAdditionalView.ViewModel:
                            PaymentsButtonAdditionalView(viewModel: additionButtonViewModel)
                            
                        default:
                            Color.clear
                            
                        }
                    }
                }
            }
            
            // bottom
            if let topItems = viewModel.top {
                
                VStack {
                    
                    Spacer()
                    
                    ForEach(topItems) { item in
                        
                        //TODO: render top items
                        Color.clear
                    }
                }
            }
            
        }
        .padding(.horizontal, 20)
        .navigationBarTitle(Text(viewModel.header.title), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: { self.presentationMode.wrappedValue.dismiss() }, label: {
            viewModel.header.backButtonIcon }))
    }
}

struct PaymentsOperationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsOperationView(viewModel: .sample)
    }
}

extension PaymentsOperationViewModel {
    
    static let sample: PaymentsOperationViewModel = {
        
        let items: [PaymentsParameterViewModel] = [PaymentsSwitchView.ViewModel.sample, PaymentsSelectView.ViewModel.selectedMock, PaymentsInfoView.ViewModel.sample, PaymentsNameView.ViewModel.normal, PaymentsNameView.ViewModel.edit, PaymentsProductView.ViewModel.sample]
        
        return PaymentsOperationViewModel(header: .init(title: "Налоги и услуги"), top: nil, content: items, bottom: nil, link: nil, bottomSheet: nil, operation: .emptyMock, model: .emptyMock)
    }()
}

